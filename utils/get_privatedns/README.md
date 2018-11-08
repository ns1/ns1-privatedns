# Script for Getting NS1 Private DNS Container Images

This shell script can be used to download and load container images to a host machine. The images can be fetched using an API key generated in the NS1 portal at https://my.nsone.net

Step 1. Generate an API Key by visiting https://my.nsone.net/#/account/settings, choose the API tab and create a new key.
Step 2. Using your new key from Step 1, run the following command or download and run the command located here:
```shell
sh <(curl -Ls https://raw.githubusercontent.com/ns1/ns1-privatedns/master/utils/get_privatedns/get_privatedns.sh -o -) -k APIKEY 
```

## Requirements
Docker Version 12.x or higher: https://docs.docker.com/engine/installation/

## Usage 
By default this will download the latest version of all available containers.

Command: 
```
ns1_get_privatedns -k <key> [OPTIONS]
```

Required Arguments:
```  
-k |--key        | NS1 api key to use for downloads.
```
Options:
```  
  -s |--sudo       | Use sudo for all docker commands.
  -d |--debug      | Enable debugging for this script.
  -c |--container  | Specify containers to download. Can be specified multiple times.
  -v |--version    | The version of the docker image to download.
  -f |--force      | Do not prompt the user for confirmation before downloading.
```








