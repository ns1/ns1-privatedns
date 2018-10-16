# Random Zone Generator

CLI tool to generate random zones and upload them to the NS1 platform (either Managed or Private).

## Requirements

- Python 3.6 or greater
- Requests (pip install requests)

## Usage

Simply call Python, provide this script as an argument and provide the required arguments for the script being called.

Arguments:

-n Number of zones to be created
-a API host, defaults to localhost
-k API key to be used
-o Org number (only needed if using an operator key)
-v Flag to disable SSL verification

For example:

```shell
$python3.6 gen_zones.py -k <API KEY> -n 2 -a api.nsone.net
*******************************************************************************
Generating zone 'zone0.test' - Status: 200
Zone created
*******************************************************************************
*******************************************************************************
Generating zone 'zone1.test' - Status: 200
Zone created
*******************************************************************************
```

If using this with Private DNS simply use the address of the API container as the API host argument (e.g., "-a 1.1.1.1").

## Clean Up

All randomly generated zones can be deleted by the accompanying helper script `clean_up.py` which deletes any zones matching the regular expression `r"^zone\d+\.test\.?$"`.

```shell
$python3.6 clean_up.py -k <API KEY> -o <Org Number> -a api.nsone.net
*******************************************************************************
Deleting zone 'zone0.test' - SSL verification: True - Status: 200
Zone deleted
*******************************************************************************
*******************************************************************************
Deleting zone 'zone1.test' - SSL verification: True - Status: 200
Zone deleted
*******************************************************************************
```
