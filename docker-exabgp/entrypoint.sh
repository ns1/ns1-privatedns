#!/usr/bin/env bash

if [ "$1" == 'exabgp' ]; then

  # Create pipes
  if [ ! -p /run/exabgp.in ]; then mkfifo /run/exabgp.in; chmod 600 /run/exabgp.in; fi
  if [ ! -p /run/exabgp.out ]; then mkfifo /run/exabgp.out; chmod 600 /run/exabgp.out; fi

  # Create env file
  if [ ! -f /usr/etc/exabgp/exabgp.env ]; then
    exabgp --fi > /usr/etc/exabgp/exabgp.env
    # bind to all interfaces
    sed -i "s/^bind = .*/bind = '0.0.0.0'/" /usr/etc/exabgp/exabgp.env 
    # run as root (otherwise ip add commands wont work)
    sed -i "s/^user = 'nobody'/user = 'root'/" /usr/etc/exabgp/exabgp.env 
  fi

  if [ ! -f /usr/etc/exabgp/exabgp.conf ]; then
    cp /usr/etc/exabgp/exabgp.conf.example /usr/etc/exabgp/exabgp.conf
  fi  

  # run 
  /usr/bin/exabgp -e /usr/etc/exabgp/exabgp.env /usr/etc/exabgp/exabgp.conf
else 
  exec "$@"
fi

