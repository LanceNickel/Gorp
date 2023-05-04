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
WORLD=$(get_active_world "$SERVER")

YEAR=$(date +"%Y")
MONTH=$(date +"%m")
DAY=$(date +"%d")
DATE_FILE=$(date +"%Y-%m-%d_%H%M-%S")

BACKUP_NAME=$WORLD-$DATE_FILE

.=$HOMEDIR/servers/$SERVER/$WORLD
DEST=$BACKUP_DEST/$SERVER/$WORLD/$YEAR/$MONTH/$DAY

TMP=/tmp/gorp







####







#### GUARDS ############

#### . not found

if [[ ! -d "$." ]]; then
        handle_error "Backup failed because the . cannot be found."
fi







#### IF SERVER IS RUNNING, SAVE PROPERLY, THEN TURN OFF AUTOSAVE ############

RUNNING=$(is_server_running "$SERVER")

if [[ "$RUNNING" == "true" ]]; then
        screen -S $SERVER -X stuff "save-all\n" || handle_error "Failed to stuff 'save-all' to $SERVER"

        I=0

        while [ true ]
        do
                sleep 0.05

                if [[ $(tail $HOMEDIR/servers/$SERVER/logs/latest.log -n1 | grep 'Saved the game') != "" ]]; then
                    break
                fi

                ((I++))

                if [[ "$I" >= 300 ]]; then
                        handle_error "Reached time out for world save."
                fi
        done

        screen -S $SERVER -X stuff "save-off\n" || handle_error "Failed to stuff 'save-off' to $SERVER"
fi







#### HANDLE FILES ############

#### Create destination dir

mkdir -p $DEST || handle_error "Failed to mkdir $DEST"



#### Copy world files to temp

echo "Copying files...."
cp -r $. $TMP/$BACKUP_NAME/$WORLD || handle_error "Failed to copy overworld files to tmp directory"
cp -r ${.}_nether $TMP/$BACKUP_NAME/${WORLD}_nether || handle_error "Failed to copy nether files to tmp directory"
cp -r ${.}_the_end $TMP/$BACKUP_NAME/${WORLD}_the_end || handle_error "Failed to copy end files to tmp directory"



#### If server is running, turn autosave back on now that we've got the files

if [[ $RUNNING == true ]]; then
        screen -S $SERVER -X stuff "save-on\n" || handle_error "Failed to stuff 'save-on' to $SERVER"
fi



#### Tarball the files

echo "Compressing files..."
cd $TMP || handle_error "Failed to cd to $TMP"
tar -czf $BACKUP_NAME.tar.gz $BACKUP_NAME >/dev/null 2>/dev/null || handle_error "Failed to compress files"



#### Copy files to destination

echo "Copying files to destination..."
cp $TMP/$BACKUP_NAME.tar.gz $DEST/ || handle_error "Failed to copy tarball in tmp to destination"







#### WE MADE IT ############

echo "Backup name: $BACKUP_NAME"
echo "World backup complete!"