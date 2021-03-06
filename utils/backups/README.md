# NS1 Enterprise Database Backup Script

## Summary

Performing frequent backups is an essential part of successful business continuity. 

The `backup.sh` script provided in this folder will make it simple to schedule, perform and transfer database backups from one or more NS1 data containers to a designated local/remote location.



## DB Backup Script Requirements

* This script must be executed on the host where the NS1 data container is running
* The docker container name is a required parameter
* Ensure sufficient disk space is available on the local and remote backup repositories


## Usage

The DB backup script takes the following arguments:

```
backup.sh <data_container_name> [-b <back-up-location>] [-f <filename-prefix>] [-d delete-old-files] [-o offsite-copy] [-l] [--dry-run]
```


### Required parameters:

`backup.sh <data_container_name>`

The docker name of the NS1 data container to be backed up


### Optional parameters:

`-b | --backup-location <path>`

Specify the directory to be used as the local backup repository. Default is the current directory.

`-d | --delete-old-files <days>`
	
Delete backups that are older than the specified <days>
	
`-f | --filename-prefix <string>`

Prepend a `<string>` to the backup file name. The default backup name is of the format "YYYY-MM-DD-HH-MM.gz", i.e: 2021-01-27_18_21.gz

`-o | --offsite-copy <script_name>`

Copy the backup to a remote repository using the specified copy script. The copy script will receive the backup filename as the only parameter.

`-l | --log-success`
	
Log a message on successful backup. The default successful operation is silent.

`--dry-run`

Perform a database backup simulation, but execute.


###  Examples

Perform a backup...

* For the `ddi_data_1` container. 
* Place a local copy of the backup in the `~/backups` directory.
* Copy the backup offsite using the script `/usr/local/bin/copy.sh`
* Log a message on success
* Delete backups older than `7` days

```
$ backup.sh ddi_data_1 -b ~/backups -f ns1_ -o /usr/local/bin/copy.sh -l -d 7
Back up complete: /opt/backups/ns1_2021-01-27_18_21.gz - 435554 bytes
```

## Installation

The DB backup script must be installed and run on all hosts running an NS1 data container, be it standalone, manual failover, or clustered mode. In the case of multiple data containers, the script will only produce a backup when the target data container is designated as the `primary` node. The backup script will do nothing and exit graciously when run on 'secondary' nodes.

It is strongly recommended to keep backup configuration parameters consistent across the cluster.

### For each host running an NS1 data container:

1. Copy the script to the designated location on the host, i.e.: `cp db_backup.sh /usr/local/sbin/`
2. Set the appropriate execution bits on the script, i.e.: `chmod ug=rx,o=- db_backup.sh`
3. Add the cron entry with the desired frequency parameters:
	`crontab -e`
	
### Cron entry examples:

Daily backups at 3:25am

`25 3 * * * /usr/local/sbin/data_backup.sh ddi_data_1 /data/backups/ns1/`

Backups every Sunday 7th at midnight (Feb 7, Mar 7, Nov 7 2021, Aug 7 2022, May 7 2023)

`0 0 7 * 7 /usr/local/sbin/data_backup.sh ddi_data_1 /data/backups/ns1/`


## Output Messages

`sanity check failed`

A docker-related issue has occurred. Docker is not present or the container ID is not found.

`ERROR: back up failed`

May indicate a problem connecting to the data container, executing the internal backup command or removing the intermediate backup file.

`This node is not primary - not performing backup`

Indicate that the data container specified to be backed up is not the primary node among the members of the cluster.
