#!/usr/bin/env bash

### [SERVER BACKUP WORKER] ########################################
#   Description:  Worker script that performs the server backup.
#   Parameters:   1: (required) Server directory name
#   Global Conf:  DEST

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################

# Copyright (C) Lance Nickel 2026.
# Distributed under GNU GPL v3.
# <https://gorp.lanickel.com/license/>



#### SETUP ############

#### Globals

. /usr/local/bin/gorpmc/functions/exit.sh
. /usr/local/bin/gorpmc/functions/params.sh
. /usr/local/bin/gorpmc/functions/functions.sh



#### Key guard

if [[ "$1" != "pleasedontdothis" ]]; then
    handle_error "Script not meant to be run directly."
fi



#### Collect arguments & additional variables

SERVER=$2

YEAR=$(date +"%Y")
MONTH=$(date +"%m")
DAY=$(date +"%d")
DATE_FILE=$(date +"%Y-%m-%d_%H%M-%S")

BACKUP_NAME="__gorp_bk__$SERVER-$DATE_FILE"

SOURCE=$HOMEDIR/servers/$SERVER
DEST=$BACKUP_DEST/servers/$SERVER/$YEAR/$MONTH/$DAY

TMP=/tmp/gorp







####







#### GUARDS ############

#### Source not found

if [[ ! -d "$SOURCE/" ]]; then
        handle_error "Backup failed because the source cannot be found."
fi







#### HANDLE FILES ############

#### Create destination and tmp

echo "Backing up "$SERVER"... (This may take a while!)"
mkdir -p "$DEST"/ || handle_error "Failed to create destination directory."
mkdir -p "$TMP"/"$BACKUP_NAME"/ || handle_error "Failed to create temp directory."



#### Copy files to tmp

echo "Creating backup..."
cp -r "$SOURCE" "$TMP"/"$BACKUP_NAME"/ || handle_error "Failed to copy server to tmp directory."



#### Tarball the files

cd "$TMP" || handle_error "Failed to cd to $TMP"
tar -czf "$BACKUP_NAME".tar.gz "$BACKUP_NAME" >/dev/null 2>/dev/null || handle_error "Failed to compress files."



#### Copy tarball to destination

cp "$TMP"/"$BACKUP_NAME".tar.gz "$DEST"/ || handle_error "Failed to copy tarball to destination."







#### WE MADE IT ############

echo "Server backup complete!"
