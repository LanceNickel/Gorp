#!/usr/bin/env bash

### [BACKUP WORKER] ################################################
#   Description:  Worker script that performs the backup tasks.
#   Parameters:   1: (required) Server directory name
#   Global Conf:  DEST

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################



# PERMISSIONS GUARD

if [[ "$EUID" != 0 ]]; then
        echo "backup.sh: Insufficient privilege. Exiting."
        exit
fi



# SCRIPT VARIABLES

SERVER=$1
WORLD=$(cat /minecraft/servers/$SERVER/server.properties | grep "level-name" | cut -d "=" -f2)

YEAR=$(date +"%Y")
MONTH=$(date +"%m")
DATE_FILE=$(date +"%Y-%m-%d_%H%M_%S")


BACKUP=$(echo "$WORLD-$DATE_FILE")
SOURCE=$(echo "/minecraft/servers/$SERVER/$WORLD")
DEST=$(cat /minecraft/gorp.conf | grep "^[^#;]" | grep 'DEST=' | cut -d '=' -f 2)
FULL_DEST=$(echo "$DEST/$WORLD/$YEAR/$MONTH")
TMP=$(echo "/minecraft/tmp/backup")



####



# SOURCE DIRECTORY GUARD

if [ -d "$SOURCE" ]; then
        sleep 0.005
else
        echo "backup.sh: Source directory does not exist. Exiting."
        exit
fi



# CHECK FOR (OR CREATE) DESTINATION DIRECTORY (GUARD)

echo "backup.sh: Backing up $WORLD..."

if [ -d "$FULL_DEST" ]; then
        sleep 0.005

elif [ -d "$DEST/$WORLD/$YEAR" ]; then
        mkdir $FULL_DEST

elif [ -d "$DEST/$WORLD" ]; then
        mkdir $DEST/$WORLD/$YEAR
        mkdir $FULL_DEST

elif [ -d "$DEST" ]; then
        mkdir $DEST/$WORLD
        mkdir $DEST/$WORLD/$YEAR
        mkdir $FULL_DEST
else
        echo "backup.sh: Backup destination cannot be created. Exiting."
        echo "backup.sh: Intended destination was $FULL_DEST"
        exit 2
fi



# FLUSH TEMP DIRECTORY

if [ -d "/minecraft/tmp" ]; then rm -rf /minecraft/tmp; fi
mkdir /minecraft/tmp
mkdir $TMP
mkdir $TMP/$BACKUP



# COPY WORLD DIRECTORIES TO TEMP

echo "backup.sh: Copying files to temp directory..."

cp -r $SOURCE $TMP/$BACKUP/$WORLD
cp -r ${SOURCE}_nether $TMP/$BACKUP/${WORLD}_nether
cp -r ${SOURCE}_the_end $TMP/$BACKUP/${WORLD}_the_end



# COMPRESS FILES IN TEMP DIRECTORY

echo "backup.sh: Compressing files..."
tar -czf $TMP/$BACKUP.tar.gz $TMP/$BACKUP >/dev/null 2>/dev/null



# COPY THE COMPRESSED BACKUP TO THE DESTINATION

echo "backup.sh: Copying files to backup directory..."
cp $TMP/$BACKUP.tar.gz $FULL_DEST/



# CLEAN UP

rm -rf /minecraft/tmp



echo "backup.sh: Backup complete."
