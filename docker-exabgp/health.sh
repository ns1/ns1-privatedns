#!/bin/sh

# count configured peers
configured_peers=`exabgpcli show neighbor configuration | grep -ce 'neighbor .* {'`

# count peers in established state
established_peers=`exabgpcli show neighbor summary | awk '{ print $4; }' | grep -c established`

# Check if exabgpcli had non-zero exit
if [ $? -ne 0 ]; then
	echo "The exabgpcli command returned non-zero status"
	exit 1
fi

# If either value is zero, something is wrong.
if [ $configured_peers -eq 0 ]; then
	echo "No configured peers"
	exit 1
fi

if [ $established_peers -eq 0 ]; then
	echo "No established peers"
	exit 1
fi

# If the values are not equal to each other, one or more configured peers must not be established
if [ $configured_peers -ne $established_peers ]; then
	echo "One or more configured peers is not in established state"
	exit 1
fi
