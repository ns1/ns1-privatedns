import asyncio
from pprint import pprint
from async_dns.resolver import ProxyResolver
from dns_data import rrtype_codes
import consistency_checker
from itertools import islice, repeat, starmap, takewhile
from operator import truth


# Bath size for scheduling async jobs - Windows may have a problem when the
# batch size is greater than 64
BATCH_SIZE = 50
LINE_SIZE = 120


def chunker(n, iterable):  # n is size of each chunk; last chunk may be smaller
    """
    Returns n size chunks of a generator. Used to schedule batches of tasks in
    async DNS look ups. Took this from Stack Overflow as it seems to work
    pretty well for my purposes.
    From:
    https://stackoverflow.com/questions/24527006/split-a-generator-into-chunks-without-pre-walking-it
    """
    chunk = takewhile(truth, map(tuple, starmap(islice, repeat((iter(iterable), n)))))
    return chunk


def program_operations(records, control_server, target_server, results):
    """
    Schedules the async loop to check all records and returns the number of DNS
    calls that were made to the caller.

    Inputs:
        - records           : generator, yields the records one at a time as a
                              tuple (domain, type)
        - control_server    : list, contains strings of IP addresses
        - target_server     : list, contains strings of IP addresses
        - results           : dict, holds any differences identified

    Returns:
        - GLOBAL_QUERY_COUNT    : int, number of DNS queries made
    """
    # Setting up control & target resolvers
    servers = {
        'control': control_server,
        'target': target_server
    }
    for batch in chunker(BATCH_SIZE, records):
        loop = asyncio.get_event_loop()
        tasks = [
            async_operations(record, servers, results) for record in batch
        ]
        loop.run_until_complete(asyncio.gather(*tasks))
    return consistency_checker.GLOBAL_QUERY_COUNT


async def async_operations(record, servers, results):
    """
    Performs the same function as it's synchronous sibling function found in
    consistency_checker.py - except 100x faster due to the power of async.

    Executes the main program logic. Actions undertaken include:
    1. Loops through the list of records and queries target and control servers
    2. Checks for differences in the responses between target and control
    3. If a difference is identified then it checks queries the servers
       multiple times in order to construct a frequency distribution of the
       answers.
    4. Compares the distributions and flags any potential differences for
       manual review

    Inputs:
        - record    : tuple (domain, type)
        - servers   : dict, contains strings of IP addresses
        - results   : dict, holds any differences identified
    """
    domain = record[0]
    record_type = record[1]
    consistency_checker.logging.debug(f'Checking {domain}_{record_type}')
    answers = {}
    for server in servers:
        answers[server] = (
            await dns_coroutine(domain, record_type, servers[server])
        )

    try:
        consistency_checker.diff_check(answers)
    except consistency_checker.ResponseDifference as e:
        consistency_checker.logging.info(
            f'diff_check: found discrepancy for {domain}_{record_type}:\n'
            f'{e.args[0]}'
        )
        print(f'Warning - discrepancy found for {domain}_{record_type}:')
        pprint(e.args[0])
        print('-' * LINE_SIZE)
        differences = e.args[0]
        if 'answers' not in differences or not consistency_checker.NUM_TRIALS:
            results[f'{domain}_{record_type}'] = str(differences)
        else:
            # I'd like to keep track of number of queries for benchmarking
            # between versions of the program
            consistency_checker.GLOBAL_QUERY_COUNT += (
                consistency_checker.NUM_TRIALS * 2
            )
            """
            3) If the value of the answers are different then we need to
            check the distribution of the answers
            """
            distributions = await get_distribution(
                domain, record_type,
                servers,
                consistency_checker.NUM_TRIALS
            )
            try:
                dist_diff = (
                    consistency_checker.distribution_diff_check(distributions)
                )
            except consistency_checker.ResponseDifference as e:
                dist_diff = e.args[0]
                consistency_checker.logging.info(
                    'distribution_diff_check: confirmed discrepancy for '
                    f'{domain}_{record_type}: \n'
                    f'{dist_diff.rstrip()}'
                )
                print(
                    f'Warning - discrepancy confirmed for '
                    f'{domain}_{record_type}\n'
                    f'{dist_diff}'
                )
                print('-' * LINE_SIZE)
                results[f'{domain}_{record_type}'] = str(distributions)
            else:
                consistency_checker.logging.info(
                    'distribution_diff_check: found no discrepancy for '
                    f'{domain}_{record_type}'
                )
                print(
                    f'Nominal results for {domain}_{record_type}',
                    end=' '
                )
                print(dist_diff.rstrip())
                print('-' * LINE_SIZE)
                consistency_checker.logging.debug(dist_diff.rstrip())
    else:
        consistency_checker.logging.debug(
            f'Nominal results: {domain}_{record_type}'
        )


async def get_distribution(domain, record_type, servers, NUM_TRIALS):
    """
    Performs the same function as it's synchronous sibling function found in
    consistency_checker.py - except 100x faster due to the power of async.

    Make repeated DNS queries for the same record to both control and target
    servers then parse the data to determine the distribution of the results.

    Inputs:
        - domain        : str, domain to be queried
        - record_type   : str, record type - e.g., "A"
        - servers       : dict, contains the resolver objects
        - NUM_TRIALS    : int, number of DNS queries to send to each server

    Returns:
        - distribution  : dict, holds the answer distribution for control and
                          target servers
    """
    distribution = {
        'control': {},
        'target': {}
    }
    num_loops = int(NUM_TRIALS / BATCH_SIZE) or 1
    for server in servers:
        responses = []

        for i in range(num_loops):
            tasks = [
                dns_coroutine(domain, record_type, servers[server]) for _ in range(BATCH_SIZE)
            ]
            responses.append(await asyncio.gather(*tasks))
        for response in responses:
            for answer in response:
                for ans in answer['answers']:
                    distribution[server][ans] = (
                        distribution[server].get(ans, 0) + 1
                    )

    return distribution


async def dns_coroutine(domain, record_type, server):
    """
    Use async_dns to make a non-blocking DNS query to a given server for the
    desired record. Returns a dict with the various parameters of the response
    that we care about such as the value of the answers, number of answers,
    status code, etc

    Inputs:
        - domain        : str, name of domain
        - record_type   : str, record type
        - server        : list, server to query

    Returns:
        -res            : dict, details of the DNS response
    """
    res = {
        'answers': [],
        'ans_count': 0,
        'ttl': None,
        'rcode': None,
        'query_time': None,
        'flags': None
    }
    # Testing shows that I need to create a new resolver object in the
    # coroutine and I cant just pass it in as an argument
    resolver = ProxyResolver()
    resolver.set_proxies(server)
    response = None
    retries = 0
    max_retries = 5
    while not response:
        retries += 1
        response = await resolver.query(domain, rrtype_codes[record_type])
        if retries > max_retries:
            return res
        if not response:
            await asyncio.sleep(5)

    res['rcode'] = response.r
    try:
        res['ttl'] = response.an[0].ttl
        for ans in response.an:
            res['answers'].append(ans.data)
            res['ans_count'] = res.get('ans_count', 0) + 1
    except IndexError:
        # This means that the field was empty and there were no answers
        # (possibly a SERVFAIL response)
        res['ans_count'] = 0
    return res
