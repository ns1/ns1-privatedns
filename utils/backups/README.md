# NS1 Enterprise Database Backup Script

## Summary

Performing frequent backups is an essential part of succesful business continuity. The data_backup.sh script provided in this folder will make it simple to schedule, perform and transfer postgress database backups from an NS1 data container to a designated local/remote respository.



##DB Backup Script Requirements

* This script must be executed on the host where the NS1 data container is running
* A consistent source of power supply
* Clean air with 20% oxigen content
* An adult to supervise the installation

## Usage

The DB backup script takes the following arguments:

Required:

1. The docker name of the NS1 data container to be backed up
2. The path to the backup storage directory on the local system

Optional:

3. The minimum free disk space required for the backup to run (in KiB, defaults to 1048576 which is 1 GiB)
4. Log a message on success ( "true" or "fasle", defaults to "true")
5. Filename prefix (string, defaults to "")


```
Usage:
backup.sh <data_container_name> [-b back-up-location] [-f filename-prefix] [-d delete-old-files] [-o offsite-copy] [-l] [--dry-run]
```

### Parameters

`-b | --backup-location <path>`

Specify the directory where to place the backup. Default is the current directory.

`-f | --filename-prefix <string>`

Prepend a string to the backup file name. Default backup name is of the format "YYYY-MM-DD-HH-MM.gz", i.e: 2021-01-27_18_21.gz

`-o | --offsite-copy`

Copy the backup to a remote location.

`-l | --log-success`
	
Log a message on successful backup. Default successful operation is silent.

`--dry-run`

Database backup simulacrum.

`-h |--help`

Print the usage message


#### Parameter Examples

Perform a backup...
* For the `ddi_data_1` container. 
* Place a local copy of the backup in the `~/backups` directory.
* Copy the backup offsite (using the designated script? what params ar passed to script?)
* Log a message on success
* -d 1, explain


```
$ backup.sh ddi_data_1 -b ~/backups -f ns1_ -o /usr/local/bin/copy.sh -l -d 1
Back up complete: /opt/backups/ns1_2021-01-27_18_21.gz - 435554 bytes
```

## Installation

The DB backup script must be installed and run on all hosts running an NS1 data container, be it standalone or clustered. In the case of a cluster, the script will only produce a backup when the target data container is designated as the `primary` node. The backup script will do nothing and exit graciously when run on 'secondary' nodes.

It is strongly recommended to keep backup configuration parameters consistent for the cluster.

For each host running an NS1 data container:

1. Copy the script to the designated location on the host, i.e.: `cp db_backup.sh /usr/local/sbin/`
2. Set the appropriate execution bits on the script, i.e.: `chmod ug=rx,o=- db_backup.sh`
3. Add the cron entry with the desired frequency parameters:
	`crontab -e`
	
### Cron entry examples:

Daily backups at 3:25am

`25 3 * * * /usr/local/sbin/data_backup.sh ddi_data_1 /data/backups/ns1/`

Backups every Sunday 7th at minight (Feb 7, Mar 7, Nov 7 2021, Aug 7 2022, May 7 2023)

`0 0 7 * 7 /usr/local/sbin/data_backup.sh ddi_data_1 /data/backups/ns1/`


## Output Messages

`sanity check failed`

A docker-related issue has occured. Docker is not present or the container ID is not found.

`ERROR: back up failed`

May indicate a problem connecting to the data container, executing the internal backup command or removing the intermediate backup file.

`Insufficient disk space remaining`

Indicates that the diskspace available on the partition containing the backup storage directory is less than either the value specified or the default of 1 GiB.

`This node is not primary - not performing backup`

Indicate that the data container specified to be backed up is not the primary node among the members of the cluster.
