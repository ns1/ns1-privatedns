#!/bin/bash

filter="tcp port 5353"
output_path="traffic.pcap"

function die() {
    if [[ $# -gt 0 ]]; then
        echo "$@";
    fi
    exit 1;
}

function usage() {
    cat <<EOF
Usage:
$(basename $BASH_SOURCE) [options]

Options:
    -f|--filter   The tcpdump filter to use for capturing packets. [default: '${filter}']
    -o|--output   The output file to write data to.                [default: '${output_path}']

Flags:
    -h|--help     Print this help page.
    -x|--debug    Print debugging information.
EOF
    die
}

function main() {
    local service="";
    local endpoint="";

    while [[ $1 ]]; do
        case "${1}" in
            -f|--filter)    filter="${2}";      shift ;;
            -o|--output)    output_path="${2}"; shift ;;

            -x|--debug)     set -x ;;
            -h|--help)      usage  ;;
        esac
        shift
    done

    tcpdump -w ${output_path} -nni any ${filter};
}

if [[ $# -le 0 ]]; then
    usage
else
    main "$@"
fi
