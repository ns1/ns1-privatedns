#! /bin/bash
read PORT
echo howdy on port $PORT
PASSKEY=$(cat /root/.passkey)
echo "Establishing remote debug session on port $PORT with passkey $PASSKEY. Paste this message to NS1 support staff to proceed." > /root/.message
while [[ $PASSKEY != $NS1KEY ]]; do
  read -p "Please enter passkey: " NS1KEY
done
echo "Remote support session established. Exit session via ctrl+c, otherwise it will end after 1 hour, or if your NS1 support staff closes the session." > /root/.message
bash -li
