#!/usr/bin/env bash

### [WORLD BACKUP WORKER] #########################################
#   Description:  Worker script that performs the world backup.
#   Parameters:   1: (required) Server directory name
#   Global Conf:  DEST

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################



#### GUARDS ################

### KEY GUARD

if [[ "$1" != "pleasedontdothis" ]]; then
    echo "backupworld.sh: Not intended to be run directly. Exit (13)."
    exit 13
fi



#### SCRIPT PARAMETERS ################

source /usr/local/bin/gorpmc/worker/i_getconfigparams.sh

SERVER=$2
WORLD=$(activeWorld "$SERVER")

YEAR=$(date +"%Y")
MONTH=$(date +"%m")
DAY=$(date +"%d")
DATE_FILE=$(date +"%Y-%m-%d_%H%M-%S")

BACKUP_NAME=$WORLD-$DATE_FILE

SOURCE=$HOMEDIR/servers/$SERVER/$WORLD
DEST=$BACKUP_DEST/$SERVER/$WORLD/$YEAR/$MONTH/$DAY

TMP=$HOMEDIR/tmp/backup



####



# SOURCE DIRECTORY RT-GUARD

if [[ -d "$SOURCE" ]]; then
        sleep 0.005
else
        echo "backupworld.sh: Backup failed because the source cannot be found. Exit (52)."
        exit 52
fi



# CHECK FOR (OR CREATE) DESTINATION DIRECTORY (RT-GUARD)

echo "Backing up $WORLD..."

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

if [[ $RUNNING == true ]]; then
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

echo "Copying files to temp directory..."

cp -r $SOURCE $TMP/$BACKUP_NAME/$WORLD
cp -r ${SOURCE}_nether $TMP/$BACKUP_NAME/${WORLD}_nether
cp -r ${SOURCE}_the_end $TMP/$BACKUP_NAME/${WORLD}_the_end



# IF SERVER IS RUNNING, TURN AUTOSAVE BACK ON

if [[ $RUNNING == true ]]; then
        screen -S $SERVER -X stuff "save-on\n"
fi



# COMPRESS FILES IN TEMP DIRECTORY

echo "Compressing files..."
cd $TMP
tar -czf $BACKUP_NAME.tar.gz $BACKUP_NAME >/dev/null 2>/dev/null



# COPY THE COMPRESSED BACKUP TO THE DESTINATION

echo "Copying files to backup directory..."
cp $TMP/$BACKUP_NAME.tar.gz $DEST/



# CLEAN UP

rm -rf $HOMEDIR/tmp



echo "Backup name: $BACKUP_NAME"
echo "World backup complete!"