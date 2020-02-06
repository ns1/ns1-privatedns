# Scripts for Downloading NS1 PrivateDNS & Enterprise DDI Container Images

This Python script can be used to download and load container images to a host machine. The images can be fetched using an API key generated in the NS1 portal at https://my.nsone.net. Note that downloads must be enabled for your account.  Contact your NS1 representative for more information.

Step 1. Generate an API Key by visiting https://my.nsone.net/#/account/settings, choose the API tab and create a new key.  

Step 2. Download the script to the local host and make it executable

```shell
wget https://raw.githubusercontent.com/ns1/ns1-privatedns/master/utils/get_privatedns/get_privatedns.py
chmod +x get_privatedns.py
```
Step 3. Run the script.  Replace $APIKEY with the NS1 API key generated above.
```shell
./get_privatedns.py -k $APIKEY
```

## Requirements
Docker Version 17.x or higher: https://docs.docker.com/engine/installation/
Python version 2.7+ or 3.x

## Usage 
By default, the script will download the latest version of all available containers.  Use the -v flag to specify a specific version for download.  Use the -c flag to specify a space separated list of containers for download.

Command: 
```
get_privatedns.py -k <key> [OPTIONS]
```

Required Arguments:
```  
  -k |--key        | NS1 api key to use for downloads.
```
Optional arguments:
```
  -h |--help       | Display help message.
  -d |--debug      | Enable debugging for this script.
  -c |--container  | Specify containers to download. Separate container names with a space.
  -v |--version    | The version of the images to download.
  -f |--force      | Do not prompt the user for confirmation before downloading.
```

# Examples
Note: All examples assume that your NS1 API key is stored in the $APIKEY environment variable.

Download all Enterprise DDI container images:

    ./get_privatedns.py -k $APIKEY

Download version 2.2.2 of Enterprise DDI:

    ./get_privatedns.py -k $APIKEY -v 2.2.2

Download only containers typically used for control hosts (data, core, xfr):

    ./get_privatedns.py -k $APIKEY -c data core xfr


