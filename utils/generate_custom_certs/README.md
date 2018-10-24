# Example Script for Generating Custom Certs

This example script models how to generate your own custom certificate bundles to be used in NS1 Private DNS. 

## Requirements
...

## Usage 
...

Command: 
```
$(basename $BASH_SOURCE) [OPTIONS]
```

Required Arguments:
```  
-z |--zone       Set the zone name to use in the certicates.
```
Options:
```
-d |--directory  Set the directory to store certifcates.     [default: '${CERT_DIR}']
-f |--force      Force overwrite of existing certificates.   [default: ${FORCE}]
-x |--debug      Enable debug logging.                       [default: false]
-h |--help       Print this help page.
```
