# Example Script for Generating Custom Certs

This example script models how to generate your own custom certificate bundles to be used in NS1 Private DNS. 

**IMPORTANT NOTE:** The included example.bundle.pem is for demonstration purposes **only** and should not be utilized in any deployment for any reason.


## Requirements
OpenSSL Version 1.x or higher [https://www.openssl.org/source/gitrepo.html]

## Usage 
Given a zone name, this script will use OpenSSL to generate a custom certificate bundle compatible with NS1's Private DNS. To use the certificate bundle, upload at a container's `Certificate & File Manager` page or using command line options.

Command: 
```
generate_custom_certs.sh [OPTIONS]
```

Required Arguments:
```  
-z |--zone       Set the zone name to use in the certicates.
```
Options:
```
-d |--directory  Set the directory to store certifcates.     [default: 'certs/']
-f |--force      Force overwrite of existing certificates.   [default: false]
-x |--debug      Enable debug logging.                       [default: false]
-h |--help       Print this help page.
```
