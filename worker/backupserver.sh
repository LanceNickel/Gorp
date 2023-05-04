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



#### SETUP ############

#### Key guard

if [[ "$1" == "pleasedontdothis" ]]; then
    handle_error "Script not meant to be run directly."
fi



#### Globals

source /usr/local/bin/gorpmc/functions/exit.sh
source /usr/local/bin/gorpmc/functions/params.sh
source /usr/local/bin/gorpmc/functions/functions.sh



#### Collect arguments & additional variables

SERVER=$2

YEAR=$(date +"%Y")
MONTH=$(date +"%m")
DAY=$(date +"%d")
DATE_FILE=$(date +"%Y-%m-%d_%H%M-%S")

BACKUP_NAME=$SERVER-$DATE_FILE

SOURCE=$HOMEDIR/servers/$SERVER
DEST=$BACKUP_DEST/$SERVER/server-backups/$YEAR/$MONTH/$DAY

TMP=/tmp/gorp







####







#### GUARDS ############

#### Source not found

if [[ ! -d "$SOURCE/" ]]; then
        handle_error "Backup failed because the source cannot be found."
fi







#### HANDLE FILES ############

#### Create destination

echo "Backing up $SERVER... (This may take a while!)"
mkdir -p $DEST/ || handle_error "Failed to mkdir $DEST/"



#### Copy files to tmp

echo "Copying files..."
cp -r $SOURCE $TMP/$BACKUP_NAME/ || handle_error "Failed to copy server to tmp directory"



#### Tarball the files

cd $TMP || handle_error "Failed to cd to $TMP"
echo "Compressing files..."
tar -czf $BACKUP_NAME.tar.gz $BACKUP_NAME >/dev/null 2>/dev/null || handle_error "Failed to compress files"



#### Copy tarball to destination

echo "Copying files to backup directory..."
cp $TMP/$BACKUP_NAME.tar.gz $DEST/ || handle_error "Failed to copy tarball to destination"







#### WE MADE IT ############

echo "Backup name: ${$BACKUP_NAME}.tar.gz"
echo "Server backup complete!"