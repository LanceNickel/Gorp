#!/usr/bin/env bash

### [WORLD BACKUP WORKER] #########################################
#   Description:  Worker script that performs the world backup.
#   Parameters:   1: (required) Server directory name
#   Global Conf:  DEST

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################



# PERMISSIONS GUARD

if [[ "$EUID" != 0 ]]; then
        echo "backupworld.sh: Insufficient privilege. Exiting."
        exit
fi



# SCRIPT VARIABLES

SERVER=$1
WORLD=$(cat $HOMEDIR/servers/$SERVER/server.properties | grep "level-name" | cut -d "=" -f2)

YEAR=$(date +"%Y")
MONTH=$(date +"%m")
DAY=$(date +"%d")
DATE_FILE=$(date +"%Y-%m-%d_%H%M-%S")

BACKUP_NAME=$WORLD-$DATE_FILE

SOURCE=$HOMEDIR/servers/$SERVER/$WORLD
DEST_ROOT=$(cat $HOMEDIR/gorp.conf | grep "^[^#;]" | grep 'BACKUPS=' | cut -d '=' -f2)
DEST=$DEST_ROOT/$SERVER/$WORLD/$YEAR/$MONTH/$DAY

TMP=$HOMEDIR/tmp/backup



####



# SOURCE DIRECTORY GUARD

if [ -d "$SOURCE" ]; then
        sleep 0.005
else
        echo "backupworld.sh: Source directory does not exist. Exiting."
        exit
fi



# CHECK FOR (OR CREATE) DESTINATION DIRECTORY (GUARD)

echo "backupworld.sh: Backing up $WORLD..."

mkdir -p $DEST



# FLUSH TEMP DIRECTORY

rm -rf $HOMEDIR/tmp
mkdir -p $TMP/$BACKUP_NAME



# FIGURE OUT IF THE SERVER IS CURRENTLY RUNNING

if [[ $(screen -ls | grep "$SERVER")  != "" ]]; then
        RUNNING=true
else
        RUNNING=false
fi



# IF SERVER IS RUNNING, SAVE PROPERLY, THEN TURN OFF AUTOSAVE

if [ $RUNNING = true ]; then
        screen -S $SERVER -X stuff "save-all\n"

        while [ true ]
        do
                sleep 0.2

                if [[ $(tail $HOMEDIR/servers/$SERVER/logs/latest.log -n1 | grep 'Saved the game') != "" ]]; then
                        break
                fi
        done

        screen -S $SERVER -X stuff "save-off\n"
fi



# COPY WORLD DIRECTORIES TO TEMP

echo "backupworld.sh: Copying files to temp directory..."

cp -r $SOURCE $TMP/$BACKUP_NAME/$WORLD
cp -r ${SOURCE}_nether $TMP/$BACKUP_NAME/${WORLD}_nether
cp -r ${SOURCE}_the_end $TMP/$BACKUP_NAME/${WORLD}_the_end



# IF SERVER IS RUNNING, TURN AUTOSAVE BACK ON

if [ $RUNNING = true ]; then
        screen -S $SERVER -X stuff "save-on\n"
fi



# COMPRESS FILES IN TEMP DIRECTORY

echo "backupworld.sh: Compressing files..."
cd $TMP
tar -czf $BACKUP_NAME.tar.gz $BACKUP_NAME >/dev/null 2>/dev/null



# COPY THE COMPRESSED BACKUP TO THE DESTINATION

echo "backupworld.sh: Copying files to backup directory..."
cp $TMP/$BACKUP_NAME.tar.gz $DEST/



# CLEAN UP

rm -rf $HOMEDIR/tmp



echo "backupworld.sh: Backup complete."
echo "backupworld.sh: Backup name: $BACKUP_NAME"
