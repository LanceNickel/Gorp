#!/usr/bin/env bash

### [SERVER BACKUP WORKER] ########################################
#   Description:  Worker script that performs the server backup.
#   Parameters:   1: (required) Server directory name
#   Global Conf:  DEST

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################



#### GUARDS ################

### KEY GUARD

if [[ "$1" != "pleasedontdothis" ]]; then
    echo "backupserver.sh: Not intended to be run directly. Exit (13)."
    exit 13
fi



#### SCRIPT PARAMETERS ################

source /usr/local/bin/gorpmc/worker/i_getconfigparams.sh

SERVER=$2

YEAR=$(date +"%Y")
MONTH=$(date +"%m")
DAY=$(date +"%d")
DATE_FILE=$(date +"%Y-%m-%d_%H%M-%S")

BACKUP_NAME=$SERVER-$DATE_FILE

SOURCE=$HOMEDIR/servers/$SERVER
DEST=$BACKUP_DEST/$SERVER/server-backups/$YEAR/$MONTH/$DAY

TMP=$HOMEDIR/tmp/backup



####



# SOURCE DIRECTORY RT-GUARD

if [[ -d "$SOURCE/" ]]; then
        sleep 0.005
else
        echo "backupserver.sh: Backup failed because the source cannot be found. Exit (52)."
        exit 52
fi



# CHECK FOR (OR CREATE) DESTINATION DIRECTORY (RT-GUARD)

echo "Backing up $SERVER... (This may take a while!)"

mkdir -p $DEST/



# FLUSH TEMP DIRECTORY

rm -rf $HOMEDIR/tmp/
mkdir -p $TMP/$BACKUP_NAME/



# COPY SERVER DIRECTORY TO TEMP

echo "Copying files to temp directory..."

cp -r $SOURCE $TMP/$BACKUP_NAME/



# COMPRESS FILES IN TEMP DIRECTORY

echo "Compressing files..."
cd $TMP
tar -czf $BACKUP_NAME.tar.gz $BACKUP_NAME >/dev/null 2>/dev/null



# COPY THE COMPRESSED BACKUP TO THE DESTINATION

echo "Copying files to backup directory..."
cp $TMP/$BACKUP_NAME.tar.gz $DEST/



# CLEAN UP

rm -rf $HOMEDIR/tmp



echo "Backup name: $BACKUP_NAME"
echo "Server backup complete!"