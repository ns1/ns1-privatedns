"""
DNS Consistency Checker
Objective:
Script aims to automate the testing of DNS server changes and flag major
differences for manual review.

Main Operation
1. Parse Inputs
2. Iterate over list of DNS records and make DNS queries for each record to
both the control and target DNS servers
3. Flag records with potential differences in results for further manual review
"""
# Due to the use of f-strings this program will not run in Python versions
# lower than 3.6
import sys

if sys.version_info < (3, 6):
    print("Python version must be >= 3.6")
    sys.exit(1)
import cli_argparser
import threading
import logging
from pprint import pprint
from timeit import default_timer
import dns.name
import dns.resolver
import dns.query
from dns_data import CHI
import async_distribution
import full_async_checker


GLOBAL_QUERY_COUNT = 0
NUM_TRIALS = 2500
LINE_SIZE = 120


class ResponseDifference(Exception):
    """
    Exception to be raised if a difference is identified between DNS responses
    """

    pass


class LockedIterator(object):
    """
    Needed to make generators thread safe - shamelessly "borrowed" from:
    https://stackoverflow.com/questions/1131430/are-generators-threadsafe
    Warning - the code in the SO post is for Python 2, very minor modifications
    were made to make it Python 3 compatible
    """

    def __init__(self, it):
        self.lock = threading.Lock()
        self.it = it.__iter__()

    def __iter__(self):
        return self

    def __next__(self):
        self.lock.acquire()
        try:
            return self.it.__next__()
        finally:
            self.lock.release()


def main(records, control_server, target_server, results_file, modes):
    """
    Main function. Accepts records list, performs queries, if a difference in
    answer values is identified then it will generate the answer distribution
    to confirm that it is a meaningful difference and not the result of
    non-deterministic Filter Chain behavior. After examining the list it will
    write the results to a CSV file
    """
    global GLOBAL_QUERY_COUNT
    logging.info(
        f"Starting testing of records in single threaded mode - " f"modes = {modes}"
    )

    results = {}
    if modes["async"]:
        GLOBAL_QUERY_COUNT += full_async_checker.program_operations(
            records, control_server, target_server, results
        )
    else:
        program_operations(
            records, control_server, target_server, results, modes["single_threaded"]
        )

    write_results(results_file, results)
    logging.info(f"Wrote results of checker to: {results_file}")


def multi_threaded_main(records, control_server, target_server, results_file, modes):
    """
    Spawns a fixed number of threads to check all records in the given input
    list. Runs the same set of steps as the regular main() function except for
    the steps required to manage the threads.
    """
    logging.info(f"Starting testing of records in multi threaded mode")

    # Make a thread safe generator
    thread_safe_records = LockedIterator(records)

    results = {}
    single_threaded = True
    # Multi threading parameters
    num_threads = 60
    threads = []
    logging.info(f"Using {num_threads} threads")

    for i in range(1, num_threads + 1):
        thread = threading.Thread(
            target=program_operations,
            args=(
                thread_safe_records,
                control_server,
                target_server,
                results,
                single_threaded,
            ),
        )
        threads.append(thread)
        thread.start()

    for thread in threads:
        thread.join()

    write_results(results_file, results)
    logging.info(f"Wrote results of checker to: {results_file}")


def program_operations(
    records, control_server, target_server, results, single_threaded
):
    """
    Executes the main program logic. Actions undertaken include:
    1. Loops through the list of records and queries target and control servers
    2. Checks for differences in the responses between target and control
    3. If a difference is identified then it checks queries the servers
       multiple times in order to construct a frequency distribution of the
       answers.
    4. Compares the distributions and flags any potential differences for
       manual review

    Inputs:
        - records           : generator, yields the records one at a time as a
                              tuple (domain, type)
        - control_server    : list, contains strings of IP addresses
        - target_server     : list, contains strings of IP addresses
        - results           : dict, holds any differences identified
        - single_threaded   : bool, flag to run process 100% synchronously
    """
    global GLOBAL_QUERY_COUNT
    # Setting up control & target resolvers
    control = get_resolver(control_server)
    target = get_resolver(target_server)

    servers = {"control": control, "target": target}
    server_addr = {"control": control_server, "target": target_server}

    # 1) Loop through list and query records
    for record in records:
        domain = record[0]
        record_type = record[1]
        logging.debug(f"Checking {domain}_{record_type}")
        answers = {}
        for server in servers:
            answers[server] = make_dns_query(domain, record_type, servers[server])

        # 2) Check for differences between both responses
        try:
            diff_check(answers)
        except ResponseDifference as e:
            logging.info(
                f"diff_check: found discrepancy for {domain}_{record_type}:\n"
                f"{e.args[0]}"
            )
            print(f"Warning - discrepancy found for {domain}_{record_type}:")
            pprint(e.args[0])
            print("-" * LINE_SIZE)
            differences = e.args[0]
            if "answers" not in differences or not NUM_TRIALS:
                results[f"{domain}_{record_type}"] = str(differences)
            else:
                # I'd like to keep track of number of queries for benchmarking
                # between versions of the program
                GLOBAL_QUERY_COUNT += NUM_TRIALS * 2
                # 3) If the value of the answers are different then we need to
                # check the distribution of the answers

                if single_threaded:
                    distributions = get_distribution(domain, record_type, servers)
                else:
                    distributions = async_distribution.get_distribution(
                        domain, record_type, server_addr, NUM_TRIALS
                    )

                try:
                    dist_diff = distribution_diff_check(distributions)
                except ResponseDifference as e:
                    dist_diff = e.args[0]
                    logging.info(
                        "distribution_diff_check: confirmed discrepancy for "
                        f"{domain}_{record_type}: \n"
                        f"{dist_diff.rstrip()}"
                    )
                    print(
                        f"Warning - discrepancy confirmed for "
                        f"{domain}_{record_type}\n"
                        f"{dist_diff}"
                    )
                    print("-" * LINE_SIZE)
                    results[f"{domain}_{record_type}"] = str(distributions)
                else:
                    logging.info(
                        "distribution_diff_check: found no discrepancy for "
                        f"{domain}_{record_type}"
                    )
                    print(f"Nominal results for {domain}_{record_type}", end=" ")
                    print(dist_diff.rstrip())
                    print("-" * LINE_SIZE)
                    logging.debug(dist_diff.rstrip())
        else:
            logging.debug(f"Nominal results: {domain}_{record_type}")


def read_records_file(filepath):
    """
    Read and process the record list file and return a generator of records to
    check. Record file should be a CSV file with each record on its own line.
    This function will yield one record at a time to allow for larger lists of
    records.

    File Format:
    Line 1: domain1,type1
    Line 2: domain2,type2
    ...
    Line N: domainN,typeN

    Inputs:
        - filepath      : str, filepath to CSV containing the record list

    Returns:
        - domain        : str, domain name of record
        - record_type   : str, record type (duh)
    """
    with open(filepath) as record_file:
        for record in record_file:
            domain, record_type = record.strip().split(",")
            yield domain.strip(), record_type.strip()


def get_num_records(filepath):
    """
    We would like to know how many records are in the file for benchmarking
    purposes. Unfortunately there does not seem to be a good way to do this.

    Inputs:
        - filepath  : str, filepath to CSV containing the record list

    Returns:
        - record_count  : int, number of records to test
    """
    # User has the option to enter a list of records in the CLI - in this case
    # we simply return the len of the list
    if isinstance(filepath, list):
        return len(filepath)

    with open(filepath) as f:
        for i, l in enumerate(f):
            pass
    record_count = i + 1
    return record_count


def get_resolver(ip_addr):
    """
    Initializes the resolver objects to be used to query the control and target
    servers

    Inputs:
        - ip-addr   : str, IP address of nameserver

    Returns:
        - server    : dns.resolver.Resolver : resolver object to do queries
    """
    server = dns.resolver.Resolver(configure=False)
    server.nameservers = ip_addr
    return server


def make_dns_query(domain, record_type, server):
    """
    Use DNSPython to make a DNS query to a given server for the desired record.
    Returns a dict with the various parameters of the response that we care
    about such as the value of the answers, number of answers, status code, etc

    Inputs:
        - server    : dns.resolver, server to query
        - domain    : str, name of domain
        - type      : str, record type

    Returns:
        -response   : dict, details of the DNS response
    """
    response = {
        "answers": [],
        "ttl": None,
        "rcode": None,
        "query_time": None,
        "flags": None,
    }
    try:
        ans = server.query(domain, record_type, raise_on_no_answer=True)
    except dns.resolver.NXDOMAIN:
        # Received NXDOMAIN response
        response["rcode"] = 3
    except dns.resolver.NoAnswer:
        # Answer count is 0 (EBOT)
        response["rcode"] = 0
    except dns.resolver.NoNameservers:
        # REFUSED
        response["rcode"] = 5
    except dns.exception.Timeout:
        pass
    else:
        response = {
            "answers": [str(a) for a in ans],
            "ttl": ans.rrset.ttl,
            "rcode": ans.response.rcode(),
            "query_time": ans.response.time,
            "flags": ans.response.flags,
        }
    response["domain"] = domain
    response["type"] = record_type
    response["ans_count"] = len(response["answers"])
    return response


def diff_check(answers):
    """
    Examine two answers and identify any non-trivial differences in the
    answers.

    Checking especially for:
        - Answer value
        - Number of answers
        - Answer TTL
        - Answer status (e.g., NOERROR, NXDOMAIN, REFUSED)
        - Answer flags

    Inputs:
        - answers   : dict, keys are  'control' and 'target'
    """
    KEY_PARAMS = ["answers", "ans_count", "ttl", "rcode", "flags"]
    diff = {}
    for parameter in KEY_PARAMS:
        p1 = answers["control"][parameter]
        p2 = answers["target"][parameter]
        # Probably inefficient to turn these lists into sets every time -
        # straight list comparison doesn't work though as it looks for the
        # order to match as well
        if isinstance(p1, list) and isinstance(p2, list):
            s1 = set(p1)
            s2 = set(p2)
            if s1 ^ s2:
                diff[parameter] = {"control": p1, "target": p2}
        else:
            if not (p1 == p2):
                diff[parameter] = {"control": p1, "target": p2}

    if diff:
        raise ResponseDifference(diff)


def get_distribution(domain, record_type, servers):
    """
    Make repeated DNS queries for the same record to both control and target
    servers then parse the data to determine the distribution of the results.

    Inputs:
        - domain        : str, domain to be queried
        - record_type   : str, record type - e.g., "A"
        - servers       : dict, contains the resolver objects

    Returns:
        - distribution  : dict, holds the answer distribution for control and
                          target servers
    """
    distribution = {"control": {}, "target": {}}

    for server in servers:
        for trial in range(NUM_TRIALS):
            resp = make_dns_query(domain, record_type, servers[server])
            for answer in resp["answers"]:
                distribution[server][answer] = distribution[server].get(answer, 0) + 1
    return distribution


def distribution_diff_check(distributions):
    """
    Compare two answer distributions and determine whether a meaningful
    difference exists between the two. Markers of a "significant" difference
    include:
    - An answer exists in one distribution but not another
    - The frequency at which a certain answer appears varies between
      distributions

    From: https://www3.nd.edu/~rwilliam/stats1/x51.pdf we will use the Pearson
    chi-square statistic

    For our test:
    H0 (null hypothesis): H0: There has been no change across time. The
    distribution of DNS answers in the target server is the same as the
    distribution of DNS answers in the control servers.

    HA: There has been change across the servers. The target answer
    distribution differs from the answer distribution of the control server.

    The Pearson chi-square statistic:
    $X^2_{c-1} = Σ(Oj - Ej)^2/E$

    Where:
    - Oj is the observed frequency for an answer in the target server
    - Ej is the expected frequency for an answer in the target server (i.e.,
      the control frequency)

    Smaller values of chi squared represent closer fit of the expected and
    observed frequencies.

    We accept H0 if our statistic X^2 is less than the tabled value at the 95%
    confidence level (look at table in dns_data.py)

    Inputs:
        - distributions : list[dict], Contains the distribution dicts for each
                          distribution to be compared

    Returns:
        - diff  : str, differences between the response distributions
    """
    servers = list(distributions.keys())
    d1 = distributions[servers[0]]
    d2 = distributions[servers[1]]

    # Identify if there are answers that appear in one server but not the other
    a1 = set(d1)
    a2 = set(d2)
    missing_answers = a2 ^ a1
    if missing_answers:
        dist_table = make_dist_table(d1, d2)
        diff = (
            f"Discrepancy in answer list - missing answers: "
            f"{missing_answers}\n"
            f"{dist_table}"
        )
        raise ResponseDifference(diff)

    chi_square = 0
    v = max((len(d1), len(d2)))
    confidence_levels = {90: 0, 95: 1, 97.5: 2, 99: 3, 99.9: 4}
    for answer in d1:
        ej = d1[answer]
        oj = d2.get(answer, 0)

        chi_square += (ej - oj) ** 2 / ej

    # Statistical test at 99% confidence level
    statistic_threshold = CHI[v][confidence_levels[99]]

    if chi_square > statistic_threshold:
        dist_table = make_dist_table(d1, d2)

        diff = (
            f"Discrepancy in answer distribution of:\nChi square value of "
            f"{round(chi_square,1)} is greater than statistical threshold of "
            f"{statistic_threshold}: \n{dist_table}"
        )
        raise ResponseDifference(diff)

    # Print the distribution even if it's ok
    dist_table = make_dist_table(d1, d2)

    diff = (
        f"Chi square value of "
        f"{round(chi_square,1)} is less than statistical threshold of "
        f"{statistic_threshold}: \n{dist_table}"
    )
    return diff


def make_dist_table(d1, d2):
    """
    Makes a nicely formated table showing the control and target servers'
    answer distribution side by side.

    Inputs:
        - d1    : dict, control server distribution
        - d2    : dict, target server distribution

    Returns:
        - side_by_side  : str, nicely formatted table showing the distributions
                          side by side
    """
    a1 = set(d1)
    a2 = set(d2)
    answers = a1 | a2
    side_by_side = (
        "Answer".center(50, "_")
        + "|"
        + "Control".center(10, "_")
        + "|"
        + "Target".center(10, "_")
        + "|\n"
    )
    for ans in answers:
        if len(str(ans)) > 45:
            ans_str = str(ans[:45])
        else:
            ans_str = str(ans)
        side_by_side = (
            side_by_side
            + ans_str.center(50, ".")
            + "|"
            + str(d1.get(ans, 0)).center(10, ".")
            + "|"
            + str(d2.get(ans, 0)).center(10, ".")
            + "|\n"
        )
    return side_by_side


def write_results(filepath, results):
    """
    Write results of checker to a CSV file and output to the console.

    Inputs:
        - filepath  : str, filepath to write to
        - results   : dict, contains entries for all differences found
    """
    with open(filepath, "w") as results_file:
        results_file.write("Record,Information\n")
        for record in results:
            information = results[record].replace("\n", "")
            results_file.write(f"{record},{information}\n")


if __name__ == "__main__":
    # Start up logging and initialization of globals
    logging.basicConfig(
        filename="consistency_checker.log",
        level=logging.DEBUG,
        format="%(asctime)s - %(levelname)s: %(message)s",
    )
    # logging.disable(logging.DEBUG)
    program_start = default_timer()
    logging.info("Start of Program")
    args = cli_argparser.parse_inputs()
    NUM_RECORDS = args["NUM_RECORDS"]
    logging.debug(f"Arguments: {args}")
    program_args = (
        args["records"],
        args["control"],
        args["target"],
        args["results"],
        {"single_threaded": args["single_threaded"], "async": args["async"]},
    )

    if args["multi_threaded"]:
        multi_threaded_main(*program_args)
    else:
        main(*program_args)

    # Just logging and printing while program finalizes
    logging.info("Program End")
    program_end = default_timer()
    runtime_s = program_end - program_start
    runtime_m = runtime_s / 60
    GLOBAL_QUERY_COUNT += NUM_RECORDS * 2
    str_to_log_print = (
        f"Program ran in {int(runtime_s)} seconds ({runtime_m:.1f} minutes) - "
        f"{NUM_RECORDS} tested -- {round(runtime_s/NUM_RECORDS, 1)} seconds "
        "per record\n"
        f"{GLOBAL_QUERY_COUNT} queries - "
        f"{GLOBAL_QUERY_COUNT/runtime_s:.1f} QPS\n"
    )
    logging.info(str_to_log_print)
    print(str_to_log_print)
