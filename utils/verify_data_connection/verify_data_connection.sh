#!/bin/bash

output_path="verify_data_connection.log"
zone_name="ns1.private"

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

Example: Verify connection to mongodb using built in tls certificates.
$(basename $BASH_SOURCE) -s "mongodb" -e "data_container.example.com"

Example: Verify connection to mongodb using custom tls certificates that use 'example.com' with their common names.
$(basename $BASH_SOURCE) -s "mongodb" -d "example.com" -e "data_container.example.com"

Options:
    -s|--service  The service to attempt to connect to.            [required]
    -e|--endpoint The endpoint to connect to.                      [required]
    -z|--zone     The zone name that is used in your custom certs. [default: ${zone_name}]
    -o|--output   The output file to write data to.                [default: ${output_path}]

Flags:
    -h|--help     Print this help page.
    -x|--debug    Print debugging information.
EOF
    die;
}

function s_client() {
    local service="${1}";
    local endpoint="${2}";

    echo "" | \
        timeout 10 \
        openssl s_client -debug -servername "${service}.${zone_name}" \
        -cert /ns1/data/etc/certs/transport.crt \
        -key /ns1/data/etc/certs/transport.key \
        -connect "${endpoint}:5353";
}

function connect() {
    local service="${1}";
    local endpoint="${2}";

    echo "Verifying connection to '${endpoint}' for service '${service}':" | tee -a ${output_path};

    local output="$(s_client ${service} ${endpoint})";

    if [[ ${output} == "" ]]; then
        echo "Failed to verify connection: timed out after 10s" | tee -a ${output_path};
    else
        echo "${output}" | tee -a ${output_path};
    fi
}

function main() {
    local service="";
    local endpoint="";

    while [[ $1 ]]; do
        case "${1}" in
            -s|--service)   service="${2}";     shift ;;
            -e|--endpoint)  endpoint="${2}";    shift ;;
            -d|--zone)      zone_name="${2}";   shift ;;
            -o|--output)    output_path="${2}"; shift ;;

            -x|--debug)     set -x ;;
            -h|--help)      usage  ;;
        esac
        shift
    done

    if [[ ${service} == "" ]]; then
        die "Error: '-s|--service' must be supplied.";
    fi

    if [[ ${endpoint} == "" ]]; then
        die "Error: '-e|--endpoint' must be supplied.";
    fi

    connect ${service} ${endpoint};
}

if [[ $# -le 0 ]]; then
    usage;
else
    main "$@";
fi
