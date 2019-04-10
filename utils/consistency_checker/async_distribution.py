import asyncio
from full_async_checker import dns_coroutine, BATCH_SIZE


def get_distribution(domain, record_type, servers, NUM_TRIALS):
    """
    This function supports the "partial" async mode of operation where the
    get_distribution function is async while the rest of the program runs
    synchronously.

    Make repeated DNS queries for the same record to both control and target
    servers then parse the data to determine the distribution of the results.
    """
    distribution = {"control": {}, "target": {}}
    # A new event loop will be spawned for every 50 requests
    # NUM_TRIALs must be divisible by 50, otherwise range(num_loops) will throw
    # an exception
    num_loops = int(NUM_TRIALS / BATCH_SIZE) or 1
    for server in servers:
        responses = []

        for i in range(num_loops):
            tasks = [
                dns_coroutine(domain, record_type, servers[server])
                for _ in range(BATCH_SIZE)
            ]
            loop = asyncio.get_event_loop()
            responses.append(loop.run_until_complete(asyncio.gather(*tasks)))
        for response in responses:
            for answer in response:
                for ans in answer["answers"]:
                    distribution[server][ans] = distribution[server].get(ans, 0) + 1
    return distribution
