#!/usr/bin/env bash

### [WORLD BACKUP WORKER] #########################################
#   Description:  Worker script that performs the world backup.
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
WORLD="world-$(get_active_world $SERVER)"

YEAR=$(date +"%Y")
MONTH=$(date +"%m")
DAY=$(date +"%d")
DATE_FILE=$(date +"%Y-%m-%d_%H%M-%S")

BACKUP_NAME="__bk__worldname_${WORLD}__date_${DATE_FILE}"

SOURCE=$HOMEDIR/servers/$SERVER/$WORLD
DEST=$BACKUP_DEST/worlds/$SERVER/$WORLD/$YEAR/$MONTH/$DAY

TMP=/tmp/gorp







####







#### GUARDS ############

#### Source not found

if [[ ! -d "$SOURCE" ]]; then
        handle_error "Backup failed because the source cannot be found."
fi







#### IF SERVER IS RUNNING, SAVE PROPERLY, THEN TURN OFF AUTOSAVE ############

RUNNING=$(is_server_running "$SERVER")

if [[ "$RUNNING" == "true" ]]; then
        echo "Saving game..."

        cmd "$SERVER" "save-all" || handle_error "Failed to cmd save-all into server."

        I=0

        while [ true ]
        do
                sleep 0.05

                if [[ $(tail "$HOMEDIR"/servers/"$SERVER"/logs/latest.log -n1 | grep 'Saved the game') != "" ]]; then
                    break
                fi

                ((I++))

                if [[ $I -ge 300 ]]; then
                        handle_error "Reached time out for world save."
                fi
        done

        cmd "$SERVER" "safe-off" || handle_error "Failed to cmd safe-off into server."
fi







#### HANDLE FILES ############

#### Create destination dir and tmp dir

mkdir -p "$DEST" || handle_error "Failed to create destination directory."
mkdir -p "$TMP"/"$BACKUP_NAME"/ || handle_error "Failed to create temp directory."



#### Copy world files to temp

echo "Creating backup..."
cp -r "$SOURCE" "$TMP"/"$BACKUP_NAME"/"$WORLD" || handle_error "Failed to copy overworld files to tmp directory."
cp -r "${SOURCE}_nether" "$TMP"/"$BACKUP_NAME"/"${WORLD}_nether" || handle_error "Failed to copy nether files to tmp directory."
cp -r "${SOURCE}_the_end" "$TMP"/"$BACKUP_NAME"/"${WORLD}_the_end" || handle_error "Failed to copy end files to tmp directory."



#### If server is running, turn autosave back on now that we've got the files

if [[ "$RUNNING" == "true" ]]; then
        cmd "$SERVER" "save-on" || handle_error "Failed to cmd save-on into server. ATTENTION!!!! THIS NEEDS TO BE MANUALLY FIXED! Your server will not auto-save until you type '/save-on' into your server chat. Do this NOW!"
fi



#### Tarball the files

cd "$TMP" || handle_error "Failed to cd to $TMP."
tar -czf "$BACKUP_NAME".tar.gz "$BACKUP_NAME" >/dev/null 2>/dev/null || handle_error "Failed to compress files."



#### Copy files to destination

cp "$TMP"/"$BACKUP_NAME".tar.gz "$DEST"/ || handle_error "Failed to copy tarball in tmp to destination."







#### WE MADE IT ############

echo "World backup complete!"
