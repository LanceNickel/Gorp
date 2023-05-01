#!/usr/bin/env bash

### [SERVER BACKUP WORKER] ########################################
#   Description:  Worker script that performs the server backup.
#   Parameters:   1: (required) Server directory name
#   Global Conf:  DEST

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################

# Copyright (C) Lance Nickel 2023.
# Distributed under GNU GPL v3.
# <https://gorp.lanickel.com/license/>



#### GUARDS ################

### KEY GUARD

if [[ "$1" == "pleasedontdothis" ]]; then
    handle_error "Script not meant to be run directly."
fi



#### SCRIPT PARAMETERS ################

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







### SOURCE DIRECTORY RT-GUARD

if [[ -d "$SOURCE/" ]]; then
        sleep 0.005
else
        handle_error "Backup failed because the source cannot be found."
fi







### CHECK FOR (OR CREATE) DESTINATION DIRECTORY (RT-GUARD)

echo "Backing up $SERVER... (This may take a while!)"

mkdir -p $DEST/ || handle_error "Failed to mkdir $DEST/"







### COPY SERVER DIRECTORY TO TEMP

echo "Copying files to temp directory..."

cp -r $SOURCE $TMP/$BACKUP_NAME/ || handle_error "Failed to cp $SOURCE to $TMP/$BACKUP_NAME/"







### COMPRESS FILES IN TEMP DIRECTORY

echo "Compressing files..."
cd $TMP || handle_error "Failed to cd to $TMP"
tar -czf $BACKUP_NAME.tar.gz $BACKUP_NAME >/dev/null 2>/dev/null || handle_error "Failed to compress files"







### COPY THE COMPRESSED BACKUP TO THE DESTINATION

echo "Copying files to backup directory..."
cp $TMP/$BACKUP_NAME.tar.gz $DEST/ || handle_error "Failed to cp $TMP/$BACKUP_NAME.tar.gz to $DEST/"







echo "Backup name: $BACKUP_NAME"
echo "Server backup complete!"