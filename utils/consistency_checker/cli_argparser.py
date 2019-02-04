import argparse
import consistency_checker


def parse_inputs():
    """
    Need to accept inputs
    - Address of control server
    - Address of target server
    - Filepath to list of records OR List of records in command line
    - Filepath to output list of differences

    Returns:
        - arguments : tuple(str), contains the arguments required to run the
                      main() function
    """
    help_texts = {
        'main': consistency_checker.__doc__,
        'control': (
            'IP address of the control server (known good behavior)'
        ),
        'target': (
            'IP address of the target server (being tested)'
        ),
        'multi': (
            'Dictate whether to use program in multi-threaded mode'
        ),
        'file_in': (
            'Optionally specify a file to list all records to be tested'
        ),
        'records': (
            'List of records to be tested: records separated by spaces and\n'
            'formated as {domain}_{type}'
        ),
        'file_out': (
            'File path for the results file'
        ),
        'async': (
            'Asynchronous operation (fastest) - by default is single-'
            'threaded, combine with  multi-threaded flag to enable '
            'multi-threaded async operations'
        ),
        'single_threaded': (
            'Single threaded operation (slowest) - purely synchronous single '
            'threaded operations'
        )
        }

    parser = argparse.ArgumentParser(
        description=help_texts['main'],
        formatter_class=argparse.RawTextHelpFormatter
    )

    server_group = parser.add_argument_group('Servers')
    records_group = parser.add_mutually_exclusive_group(required=True)
    results_group = parser.add_argument_group('Results')
    mode_group = parser.add_argument_group('Mode of Operation')

    # Set defaults for arguments
    def_file_in = 'records.csv'
    def_file_out = 'results.csv'
    def_control = '198.51.44.1'

    server_group.add_argument(
        '-c',
        '--control',
        type=str,
        help=help_texts['control'],
        default=def_control
    )

    server_group.add_argument(
        '-t',
        '--target',
        type=str,
        help=help_texts['target'],
        required=True
    )

    mode_group.add_argument(
        '-m',
        '--multi_threaded',
        action='store_true',
        help=help_texts['multi'],
    )

    mode_group.add_argument(
        '-a',
        '--async_ops',
        action='store_true',
        help=help_texts['async'],
    )

    mode_group.add_argument(
        '-s',
        '--single_threaded',
        action='store_true',
        help=help_texts['single_threaded'],
    )

    records_group.add_argument(
        '-r',
        '--records',
        type=str,
        help=help_texts['file_in'],
        default=def_file_in,
    )

    records_group.add_argument(
        '-l',
        '--records_list',
        type=str,
        nargs='+',
        help=help_texts['records']
    )

    results_group.add_argument(
        '-f',
        '--results',
        type=str,
        help=help_texts['file_out'],
        default=def_file_out
    )

    args = parser.parse_args()

    NUM_RECORDS = consistency_checker.get_num_records(
        args.records or args.records_list
    )

    if args.multi_threaded and args.async_ops:
        raise NotImplementedError(
            'Program cannot be run both asynchronous and multi-threaded'
        )
    if args.multi_threaded and args.single_threaded:
        raise ValueError(
            'Single threaded and multi threaded modes cannot be used together'
        )

    if args.records:
        records = consistency_checker.read_records_file(args.records)

    else:
        records = args.records_list
        records = [
            (record.split('_')[0], record.split('_')[1]) for record in records
        ]

    arguments = {
        'records': records,
        'control': [args.control],
        'target': [args.target],
        'results': args.results,
        'multi_threaded': args.multi_threaded,
        'async': args.async_ops,
        'NUM_RECORDS': NUM_RECORDS,
        'single_threaded': args.single_threaded
    }
    return arguments
