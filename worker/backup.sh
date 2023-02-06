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
DAY=$(date +"%d")
DATE_FILE=$(date +"%Y-%m-%d_%H%M-%S")

BACKUP_NAME=$WORLD-$DATE_FILE

SOURCE=/minecraft/servers/$SERVER/$WORLD
DEST_ROOT=$(cat /minecraft/gorp.conf | grep "^[^#;]" | grep 'DEST=' | cut -d '=' -f 2)
DEST=$DEST_ROOT/$SERVER/$WORLD/$YEAR/$MONTH/$DAY

TMP=/minecraft/tmp/backup



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

mkdir -p $DEST



# FLUSH TEMP DIRECTORY

rm -rf /minecraft/tmp
mkdir -p $TMP/$BACKUP_NAME



# ISSUE SAVE COMMAND... WAIT UNTIL FINISHED

screen -S $SERVER -X stuff "save-all\n"

while [ true ]
do
        sleep 0.2

        if [[ $(tail /minecraft/servers/$SERVER/logs/latest.log -n1 | grep 'Saved the game') != "" ]]; then
                break
        fi
done



# TURN OFF AUTOSAVE

screen -S $SERVER -X stuff "save-off\n"



# COPY WORLD DIRECTORIES TO TEMP

echo "backup.sh: Copying files to temp directory..."

cp -r $SOURCE $TMP/$BACKUP_NAME/$WORLD
cp -r ${SOURCE}_nether $TMP/$BACKUP_NAME/${WORLD}_nether
cp -r ${SOURCE}_the_end $TMP/$BACKUP_NAME/${WORLD}_the_end



# TURN AUTOSAVE BACK ON

screen -S $SERVER -X stuff "save-on\n"



# COMPRESS FILES IN TEMP DIRECTORY

echo "backup.sh: Compressing files..."
cd $TMP
tar -czf $BACKUP_NAME.tar.gz $BACKUP_NAME >/dev/null 2>/dev/null



# COPY THE COMPRESSED BACKUP TO THE DESTINATION

echo "backup.sh: Copying files to backup directory..."
cp $TMP/$BACKUP_NAME.tar.gz $DEST/



# CLEAN UP

rm -rf /minecraft/tmp



echo "backup.sh: Backup complete."
