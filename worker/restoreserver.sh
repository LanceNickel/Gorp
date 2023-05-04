#!/usr/bin/env bash

### [SERVER RESTORE WORKER] #######################################
#   Description:  Worker script that performs server restore tasks.
#   Parameters:   1: (required) Server directory name

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################

# Copyright (C) Lance Nickel 2023.
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

cd $BACKUP_DEST/servers/$SERVER/ || handle_error "Failed to cd to server backups directory."



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



#### Select file

echo -e "\nSelect backup to restore from\nDate format is YYYY-MM-DD_HHMM-SS"

select d in *;
do
    test -n "$d" && break
    echo ">>> Invalid selection"
done

FILE_TO_RESTORE="$d"
FOLDER_TO_RESTORE=$(echo $d | cut -d '.' -f1)







#### USER CONFIRMATION (if necessary) ############

if [[ -d "$HOMEDIR/servers/$SERVER/" ]]; then
    echo "Restoring this server will overwrite the current version."

    read -r -p "Take a backup of the current server? [y/n] " response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        /usr/local/bin/gorpmc/action/mcbackupserver $1 $SERVER
    fi
fi







#### RESTORE THE SERVER ############

#### Delete current server (if it exists)

if [[ -d "$HOMEDIR/servers/$SERVER/" ]]; then
    rm -rf $HOMEDIR/servers/$SERVER/ || handle_error "Failed to delete existing server"
fi



#### Move the tarball to tmp

echo "Restoring server..."
mkdir -p /tmp/gorp/restore || handle_error "Failed to make tmp directory"
cp $BACKUP_DEST/servers/$SERVER/$YEAR/$MONTH/$DAY/$FILE_TO_RESTORE /tmp/gorp/restore/ || handle_error "Failed to copy archive to tmp directory"



#### Unarchive the file in tmp & move to servers

tar -xf /tmp/gorp/restore/$FILE_TO_RESTORE -C /tmp/gorp/restore/ || handle_error "Failed to extract server backup files"
cp -r /tmp/gorp/restore/$FOLDER_TO_RESTORE/* $HOMEDIR/servers/ || handle_error "Failed to copy restored files to server"







#### WE MADE IT ############

echo "Server restored from backup!"