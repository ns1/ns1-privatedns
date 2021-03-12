#! /bin/bash

echo "This will install remote debug scripts from the public ns1-privatedns repo into this container."
read -p "Enter y to proceed: " CONFIRM </dev/tty

if [[ $CONFIRM == "y" ]]; then
  curl https://raw.githubusercontent.com/ns1/ns1-privatedns/f1cd6dd996044e368099d15a6968d006b60202f5/utils/rdbg/rdbg.sh > /usr/local/bin/rdbg
  curl https://raw.githubusercontent.com/ns1/ns1-privatedns/f1cd6dd996044e368099d15a6968d006b60202f5/utils/rdbg/rdbg_auth.sh > /usr/local/bin/auth.sh
  chmod +x /usr/local/bin/rdbg /usr/local/bin/auth.sh
  echo "Would you like to begin a remote debug session now?"
  read -p "Enter y to proceed: " BEGIN </dev/tty
  if [[ $BEGIN == "y" ]]; then
    rdbg
  else
    echo "You can initiate a remote debug session at any time by entering the command rdbg in this container." 
  fi;
fi;
