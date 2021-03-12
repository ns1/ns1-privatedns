#! /bin/bash

# cleanup in case of previous panic
rm -f /root/.message > /dev/null 2>&1 
rm -f /root/.passkey > /dev/null 2>&1 
kill -9 $(cat /root/.debug.pid 2> /dev/null) > /dev/null 2>&1 
rm -f /debug/.pid > /dev/null 2>&1 

echo "This will begin a remote debug session with NS1 support staff. If you continue, you will be granting NS1 shell access to this container. We will not be able to impact anything else running on this host outside of the container. You will be asked to create a temporary passkey for NS1 staff to authenticate and verify that they are connecting to this session."
echo "Enter a passkey to continue."
read -p "Passkey: " PASSKEY </dev/tty
echo $PASSKEY > /root/.passkey

# initiate reverse shell
socat exec:'/usr/local/bin/auth.sh',pty,stderr,setsid,sigint,sane openssl-connect:'remote-debug.ns1.com:4536',verify=1 & > /dev/null

# note pid for better proc control
echo $! > /root/.debug.pid

# convert all exit-able events to exit
trap "exit" INT TERM
# exec killall on exit
trap killall EXIT

# cleanup temp files, kill debug.pid, exit
function killall () {
  echo
  echo "Killing debug session."
  PID=$(cat /root/.debug.pid)
  rm -f /root/.message
  rm -f /root/.passkey
  rm -f /root/.debug.pid
  kill -9 $PID > /dev/null 2>&1 
  exit 0
}

# timeouts
sleep 3300 && echo "Your support session has 5 minutes remaining." &
sleep 3600 && echo "Session timeout reached, exiting" && killall &

# watch for /root/.message from remote shell
inotifywait -m -r -e modify -q /root |
while read events; do
  cat /root/.message 2> /dev/null
  rm -f /root/.message 2>&1 > /dev/null
done
