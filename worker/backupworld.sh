#!/usr/bin/env bash

### [WORLD BACKUP WORKER] #########################################
#   Description:  Worker script that performs the world backup.
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
WORLD=$(activeWorld "$SERVER")

YEAR=$(date +"%Y")
MONTH=$(date +"%m")
DAY=$(date +"%d")
DATE_FILE=$(date +"%Y-%m-%d_%H%M-%S")

BACKUP_NAME=$WORLD-$DATE_FILE

SOURCE=$HOMEDIR/servers/$SERVER/$WORLD
DEST=$BACKUP_DEST/$SERVER/$WORLD/$YEAR/$MONTH/$DAY

TMP=/tmp/gorp







####







### SOURCE DIRECTORY RT-GUARD

if [[ -d "$SOURCE" ]]; then
        sleep 0.005
else
        handle_error "Backup failed because the source cannot be found."
fi







### CHECK FOR (OR CREATE) DESTINATION DIRECTORY (RT-GUARD)

echo "Backing up $WORLD..."

mkdir -p $DEST || handle_error "Failed to mkdir $DEST"







### FIGURE OUT IF THE SERVER IS CURRENTLY RUNNING

if [[ $(screen -ls | grep "$SERVER")  != "" ]]; then
        RUNNING=true
else
        RUNNING=false
fi







### IF SERVER IS RUNNING, SAVE PROPERLY, THEN TURN OFF AUTOSAVE

if [[ $RUNNING == true ]]; then
        screen -S $SERVER -X stuff "save-all\n" || handle_error "Failed to stuff 'save-all' to $SERVER"

        while [ true ]
        do
                sleep 0.2

                if [[ $(tail $HOMEDIR/servers/$SERVER/logs/latest.log -n1 | grep 'Saved the game') != "" ]]; then
                        break
                fi
        done

        screen -S $SERVER -X stuff "save-off\n" || handle_error "Failed to stuff 'save-off' to $SERVER"
fi







### COPY WORLD DIRECTORIES TO TEMP

echo "Copying files to temp directory..."

cp -r $SOURCE $TMP/$BACKUP_NAME/$WORLD || handle_error "Failed to cp $SOURCE to $TMP/$BACKUP_NAME/$WORLD"
cp -r ${SOURCE}_nether $TMP/$BACKUP_NAME/${WORLD}_nether || handle_error "Failed to cp ${SOURCE}_nether to $TMP/$BACKUP_NAME/${WORLD}_nether"
cp -r ${SOURCE}_the_end $TMP/$BACKUP_NAME/${WORLD}_the_end || handle_error "Failed to cp ${SOURCE}_the_end to $TMP/$BACKUP_NAME/${WORLD}_the_end"







### IF SERVER IS RUNNING, TURN AUTOSAVE BACK ON

if [[ $RUNNING == true ]]; then
        screen -S $SERVER -X stuff "save-on\n" || handle_error "Failed to stuff 'save-on' to $SERVER"
fi







### COMPRESS FILES IN TEMP DIRECTORY

echo "Compressing files..."
cd $TMP || handle_error "Failed to cd to $TMP"
tar -czf $BACKUP_NAME.tar.gz $BACKUP_NAME >/dev/null 2>/dev/null || handle_error "Failed to compress files."







### COPY THE COMPRESSED BACKUP TO THE DESTINATION

echo "Copying files to backup directory..."
cp $TMP/$BACKUP_NAME.tar.gz $DEST/ || handle_error "Failed to cp $TMP/$BACKUP_NAME.tar.gz to $DEST/"







echo "Backup name: $BACKUP_NAME"
echo "World backup complete!"