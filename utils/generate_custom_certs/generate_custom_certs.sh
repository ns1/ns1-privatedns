#!/bin/bash

CERT_DIR="certs/"
FORCE="false"
ZONE=""
TYPE="ECDSA"

function die() {
    [[ $# -gt 0 ]] && echo "$@"
    exit 1
}

function usage() {
    cat <<EOF
Usage:
$(basename $BASH_SOURCE) [options]

Flags:
    -z|--zone       Set the zone name to use in the certicates.            [required]
    -t|--type       Set the type of key and cert to produce (RSA, ECDSA)   [default: ${TYPE}]
    -d|--directory  Set the directory to store certifcates.                [default: '${CERT_DIR}']
    -f|--force      Force overwrite of existing certificates.              [default: ${FORCE}]
    -x|--debug      Enable debug logging.                                  [default: false]
    -h|--help       Print this help page.
EOF
    die
}

while [[ $1 ]]; do
    case "$1" in
        -z|--zone)       ZONE="${2}"; shift ;;
        -t|--type)       TYPE="${2}"; shift ;;
        -d|--directory)  CERT_DIR="${2}"; shift ;;
        -f|--force)      FORCE="true" ;;

        -x|--debug)    set -x ;;
        -h|--help|*)   usage ;;
    esac
    shift
done

if [[ ${ZONE} == "" ]]; then
    die "You must specify '-z|--zone'"
fi

if [[ ${TYPE} != "ECDSA" ]] && [[ ${TYPE} != "RSA" ]]; then
    die "Invalid type specified, must be ECDSA or RSA"
fi

if [[ ${FORCE} == "true" ]] || [[ ! -d ${CERT_DIR} ]]; then
    # Create base level certificate storage directories on the filesystem
    rm -rf ${CERT_DIR}
    mkdir -p ${CERT_DIR}
elif [[ -d ${CERT_DIR} ]]; then
    echo "Certificate directory '${CERT_DIR}', already exists and '-f|--force' was not used exiting."
    exit 1
fi

# Generate the internal CA if it doesn't exist.
if [[ ! -f ${CERT_DIR}/ca.crt ]] || [[ ! -f ${CERT_DIR}/ca.key ]]; then
    if [[ ${TYPE} == "RSA" ]]; then
        openssl genrsa -out ${CERT_DIR}/ca.key 4096
        openssl req -x509 -new -nodes -key ${CERT_DIR}/ca.key -sha256 -days 36500 -out ${CERT_DIR}/ca.crt -subj "/C=US/ST=New York/L=New York/O=NS1/OU=Engineering/CN=ca.${ZONE}"
    elif [[ ${TYPE} == "ECDSA" ]]; then
        openssl ecparam -genkey -name prime256v1 -out ${CERT_DIR}/ca.key
        openssl req -x509 -new -nodes -key ${CERT_DIR}/ca.key -sha256 -extensions v3_ca -days 825 -out ${CERT_DIR}/ca.crt -subj "/C=US/ST=New York/L=New York/O=NS1/OU=Engineering/CN=ca.${ZONE}" -config <(printf "[ v3_ca ]\nsubjectKeyIdentifier=hash\nauthorityKeyIdentifier=keyid:always,issuer\nbasicConstraints = critical,CA:true\n[req]\ndistinguished_name = req_distinguished_name\n[req_distinguished_name]\nC = US\n")
    fi
fi


# Generate the base level transport certificate/key pair if it doesn't exist.
if [[ ! -f ${CERT_DIR}/transport.crt ]] || [[ ! -f ${CERT_DIR}/transport.key ]]; then
    if [[ ${TYPE} == "RSA" ]]; then
        openssl genrsa -out ${CERT_DIR}/transport.key 4096
        openssl req -new -key ${CERT_DIR}/transport.key -out ${CERT_DIR}/transport.csr -subj "/C=US/ST=New York/L=New York/O=NS1/OU=Engineering/CN=*.${ZONE}"
        openssl x509 -req -in ${CERT_DIR}/transport.csr -CA ${CERT_DIR}/ca.crt -CAkey ${CERT_DIR}/ca.key -CAcreateserial -out ${CERT_DIR}/transport.crt -days 36500 -sha256
    elif [[ ${TYPE} == "ECDSA" ]]; then
        openssl ecparam -genkey -name prime256v1 -out ${CERT_DIR}/transport.key
        openssl req -new -key ${CERT_DIR}/transport.key -out ${CERT_DIR}/transport.csr -extensions v3_req -subj "/C=US/ST=New York/L=New York/O=NS1/OU=Engineering/CN=*.${ZONE}" -config <(printf "[v3_req]\nkeyUsage = keyEncipherment, dataEncipherment\nextendedKeyUsage = serverAuth\nsubjectAltName = @alt_names\n[req]\ndistinguished_name = req_distinguished_name\n[req_distinguished_name]\nC = US\n[alt_names]\nDNS.1 = *.{$ZONE}")
        openssl x509 -extfile <(printf "subjectAltName=DNS:*.${ZONE}\nextendedKeyUsage=serverAuth") -req -in ${CERT_DIR}/transport.csr -CA ${CERT_DIR}/ca.crt -CAkey ${CERT_DIR}/ca.key -CAcreateserial -out ${CERT_DIR}/transport.crt -days 825 -sha256
    fi
fi

# Generate the client certifcate for testing management/web TLS.
if [[ ! -f ${CERT_DIR}/client.p12 ]]; then
    openssl pkcs12 -export -clcerts -in ${CERT_DIR}/transport.crt -inkey ${CERT_DIR}/transport.key -out ${CERT_DIR}/client.p12 -passout pass:
fi

# Generate the combined PEM format transport/management/web certificate with the transport certificate/key pair if it doesn't exist.
if [[ ! -f ${CERT_DIR}/transport.bundle.pem ]]; then
    cat ${CERT_DIR}/transport.key >  ${CERT_DIR}/transport.bundle.pem
    cat ${CERT_DIR}/transport.crt >> ${CERT_DIR}/transport.bundle.pem
    cat ${CERT_DIR}/ca.crt        >> ${CERT_DIR}/transport.bundle.pem
fi

if [[ ! -f ${CERT_DIR}/management.bundle.pem ]]; then
    cat ${CERT_DIR}/transport.key >  ${CERT_DIR}/management.bundle.pem
    cat ${CERT_DIR}/transport.crt >> ${CERT_DIR}/management.bundle.pem
    cat ${CERT_DIR}/ca.crt        >> ${CERT_DIR}/management.bundle.pem
fi

if [[ ! -f ${CERT_DIR}/web.bundle.pem ]]; then
    cat ${CERT_DIR}/transport.key >  ${CERT_DIR}/web.bundle.pem
    cat ${CERT_DIR}/transport.crt >> ${CERT_DIR}/web.bundle.pem
    cat ${CERT_DIR}/ca.crt        >> ${CERT_DIR}/web.bundle.pem
fi
