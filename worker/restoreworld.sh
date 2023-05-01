#!/usr/bin/env bash

### [WORLD RESTORE WORKER] ########################################
#   Description:  Worker script that performs world restore tasks.
#   Parameters:   1: (required) Server directory name

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
CURRENT_LEVEL_NAME=$(activeWorld "$SERVER")







####







### SELECT FROM AVAILABLE WORLD FILES

cd $BACKUP_DEST/$SERVER

echo -e "\nPlease select a world (level-name in server.properties)"

select d in *;
do
    test -n "$d" && break
    echo ">>> Invalid selection"
done

cd "$d" || handle_error "Failed to cd to $d"
RESTORE_LEVEL_NAME=$d







### SELECT FROM AVAILABLE YEARS
echo -e "\nSelect year"

select d in *;
do
    test -n "$d" && break
    echo ">>> Invalid selection"
done

cd "$d" || handle_error "Failed to cd to $d"
YEAR=$d







### SELECT FROM AVAILABLE MONTHS

echo -e "\nSelect month"

select d in *;
do
    test -n "$d" && break
    echo ">>> Invalid selection"
done

cd "$d" || handle_error "Failed to cd to $d"
MONTH=$d







### SELECT FROM AVAILABLE DAYS

echo -e "\nSelect day of month"

select d in *;
do
    test -n "$d" && break
    echo ">>> Invalid selection"
done

cd "$d" || handle_error "Failed to cd to $d"
DAY=$d







### SELECT BACKUP FILE

echo -e "\nSelect backup to restore from\nDate format is YYYY-MM-DD_HHMM-SS"

select d in *;
do
    test -n "$d" && break
    echo ">>> Invalid selection"
done

FILE_TO_RESTORE="$d"
FOLDER_TO_RESTORE=$(echo $d | cut -d '.' -f1)







### BACKUP CURRENT WORLD

echo "Backing up current world..."

source /usr/local/bin/gorpmc/action/mcbackupworld pleasedontdothis $SERVER || handle_error "Failed to back up world"







### FLUSH CURRENT WORLD

echo "Restoring selected files..."

rm -rf $HOMEDIR/servers/$SERVER/${CURRENT_LEVEL_NAME}* || handle_error "Failed to delete existing world"







### RESTORE WORLD

mkdir -p /tmp/gorp/restore || handle_error "Failed to make tmp directory"

cp $BACKUP_DEST/$SERVER/$RESTORE_LEVEL_NAME/$YEAR/$MONTH/$DAY/$FILE_TO_RESTORE /tmp/gorp/restore/ || handle_error "Failed to copy backup archive to tmp"

tar -xf /tmp/gorp/restore/$FILE_TO_RESTORE -C /tmp/gorp/restore/ || handle_error "Failed to extract backup files"

cp -r /tmp/gorp/restore/$FOLDER_TO_RESTORE/* $HOMEDIR/servers/$SERVER/ || handle_error "Failed to copy restored files to server"







echo "World restored from backup!"