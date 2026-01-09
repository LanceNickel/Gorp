#!/usr/bin/env bash

### [WORLD RESTORE WORKER] ########################################
#   Description:  Worker script that performs world restore tasks.
#   Parameters:   1: (required) Server directory name

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







####







#### SELECT FROM AVAILABLE BACKUPS ############

cd $BACKUP_DEST/worlds/$SERVER

echo -e "\nPlease select a world (level-name in server.properties)"

select d in *;
do
    test -n "$d" && break
    echo ">>> Invalid selection"
done

cd "$d" || handle_error "Failed to cd to $d"
RESTORE_LEVEL_NAME=$d



#### Select year

echo -e "\nSelect year"

select d in *;
do
    test -n "$d" && break
    echo ">>> Invalid selection"
done

cd "$d" || handle_error "Failed to cd to $d"
YEAR=$d



#### Select month

echo -e "\nSelect month"

select d in *;
do
    test -n "$d" && break
    echo ">>> Invalid selection"
done

cd "$d" || handle_error "Failed to cd to $d"
MONTH=$d



#### Select day

echo -e "\nSelect day of month"

select d in *;
do
    test -n "$d" && break
    echo ">>> Invalid selection"
done

cd "$d" || handle_error "Failed to cd to $d"
DAY=$d



#### Select backup file

echo -e "\nSelect backup to restore from\nDate format is YYYY-MM-DD_HHMM-SS"

select d in *;
do
    test -n "$d" && break
    echo ">>> Invalid selection"
done

FILE_TO_RESTORE="$d"
FOLDER_TO_RESTORE=$(echo $d | cut -d '.' -f1)







#### USER CONFIRMATION (if necessary) ############

if [[ -d "$HOMEDIR/servers/$SERVER/$RESTORE_LEVEL_NAME" ]]; then
    echo "Restoring this world will overwrite the current version."

    read -r -p "Confirm overwrite (make SURE you have a backup)? [y/n] " response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        sleep 0.005
    else
        handle_error "You answered the prompt wrong!"
    fi
fi







#### RESTORE WORLD ############

#### Delete current world (if it exists)

if [[ -d "$HOMEDIR/servers/$SERVER/$RESTORE_LEVEL_NAME/" ]]; then
    rm -rf $HOMEDIR/servers/$SERVER/${RESTORE_LEVEL_NAME}* || handle_error "Failed to delete existing world."
fi



#### Move tarball to tmp

echo "Restoring world..."
mkdir -p /tmp/gorp/restore || handle_error "Failed to make tmp directory"
cp $BACKUP_DEST/worlds/$SERVER/$RESTORE_LEVEL_NAME/$YEAR/$MONTH/$DAY/$FILE_TO_RESTORE /tmp/gorp/restore/ || handle_error "Failed to copy backup archive to tmp."



#### Unarchive and move to server

tar -xf /tmp/gorp/restore/$FILE_TO_RESTORE -C /tmp/gorp/restore/ || handle_error "Failed to extract backup files."
cp -r /tmp/gorp/restore/$FOLDER_TO_RESTORE/* $HOMEDIR/servers/$SERVER/ || handle_error "Failed to copy restored files to server."







#### WE MADE IT ############

echo "World restored from backup!"
