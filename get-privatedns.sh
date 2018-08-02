#!/bin/sh

die() {
  echo "$@" >&2 && exit 1
}

ns1_curl() {
  curl -H "X-NSONE-Key: $NS1_API_KEY" ${DEBUG:+-vvv} "$@"
}

help() {
  HELP="$(cat<<EOF
Usage: ns1_get_privatedns -k <key> [OPTIONS]

By default this will download the latest version of all available containers.

Required Args:
  -k|--key        | NS1 api key to use for downloads.
Options:
  -s|--sudo       | Use sudo for all docker commands.
  -d|--debug      | Enable debugging for this script.
  -c|--container  | Specify containers to download. Can be specified multiple times.
  -v|--version    | The version of the docker image to download.
  -f|--force      | Do not prompt the user for confirmation before downloading.
EOF
)"
die "$HELP"
}

get_container () {
  curl -L -o - ${DEBUG:+-vvv} "$@"
}

get_latest_document () {
  ns1_curl -s -f 'https://api.nsone.net/v1/products/privatedns/available?latest=true'
}

get_latest_stream() {
  grep -oE '"stream":{[^}]*"stream":"[0-9\.]+"([^}]+)?}' | grep -oE '"stream":"[0-9\.]+"' | grep -oE '[0-9\.]+'
}

get_latest_version() {
  grep -oE '"version":"[0-9\.]+"' | grep -oE '[0-9\.]+'
}

get_available_containers() {
  grep -oE '"resources":\[[^]]+]' | grep -oE '\[.+\]' | tr -d '][]"' | tr ',' ' '
}

confirm_download() {
  echo "This will Download:"
  for container in $CONTAINERS ; do
    echo "ns1inc/privatedns_$container:$VERSION"
  done
  echo
  read -r -p "Are you sure you want to continue? [y/N] " response
  case "$response" in
      [yY][eE][sS]|[yY]) 
          true
          ;;
      *)
          exit 1
          ;;
  esac
}

clean_container_name() {
  echo "$@" | sed 's^ns1inc/privatedns_^^'
}

get_container_url() {
  # head doesn't work on our api
  ns1_curl -vf "https://api.nsone.net/v1/products/privatedns?version=$1&type=docker&resource=$2" 2>&1 | grep -Fi 'location:' | grep -o 'https://.*' | tr '\n\r' '\0'
}

preflight(){
  printf "Checking installer deps... "
  for command in docker curl grep tr sed ; do
    which $command 2>/dev/null >/dev/null || die "$command not found in path and required to run this script"
  done
  if ! $DOCKER_SUDO docker info >/dev/null 2>/dev/null ; then
    die "Unable to run docker command."
  fi
  echo "ok."
}

main() {

  preflight

  export CONTAINERS="${CONTAINERS}"
  export NS1_API_KEY="${NS1_API_KEY}"
  export VERSION="${VERSION}"
  export DOCKER_SUDO="${DOCKER_SUDO:+sudo}"

  while [ ! -z $1 ] ; do
    case $1 in
      -d|--debug) DEBUG=1 ; set -x ;;
      -c|--container) CONTAINERS="$CONTAINERS $(clean_container_name $2)" ; shift ;;
      -k|--key) NS1_API_KEY="$2"; shift ;;
      -v|--version) VERSION="$2" ; shift ;;
      -f|--force) FORCE=1 ;;
      -s|--sudo) DOCKER_SUDO=sudo ;;
      *) help ;;
    esac
    shift
  done

  if [ -z $NS1_API_KEY ] ; then
    die "You must provide an NS1 API Key"
  fi

  printf "Determining version availability... "
  LATEST="$(get_latest_document)"
  if [ $? -ne 0 ] ; then
    echo
    die "Unable to get version information please run this script in debug mode and report breakages."
  fi
  echo "ok."
  VERSION=${VERSION:-$(echo "${LATEST}" | get_latest_version)}
  CONTAINERS=${CONTAINERS:-$(echo "${LATEST}" | get_available_containers)}

  if [ -z $FORCE ] ; then
    confirm_download
  fi

  for container in $CONTAINERS ; do
    echo "Downloading ns1inc/privatedns_$container:$VERSION"
    URL="$(get_container_url $VERSION $container)"
    if [ -z "$URL" ] ; then
      echo "Failed to find ns1inc/privatedns_$container:$VERSION"
    else
      get_container "$URL" | ${DOCKER_SUDO} docker load
    fi
  done

}

main "$@"
