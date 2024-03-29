#!/usr/bin/env bash

### [GORP UPGRADE WORKER] #########################################
#   Description:  Worker script that performs the upgrade tasks.
#   Parameters:   None

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







####







#### STAGE 1: INSTALL NEW FILES ############

echo "Upgrading Gorp..."



#### Make scripts executable

chmod +x /tmp/gorp/updatefiles/action/* || handle_error "Failed to +x actions"
chmod +x /tmp/gorp/updatefiles/functions/* || handle_error "Failed to +x functions"
chmod +x /tmp/gorp/updatefiles/worker/* || handle_error "Failed to +x workers"
chmod +x /tmp/gorp/updatefiles/argparse.sh || handle_error "Failed to +x argparse"
chmod +x /tmp/gorp/updatefiles/entry.sh || handle_error "Failed to +x entry"
chmod +x /tmp/gorp/updatefiles/gorp || handle_error "Failed to +x gorp"
chmod +x /tmp/gorp/updatefiles/run.sh || handle_error "Failed to +x run"



#### Delete current installation

sudo rm -rf /usr/local/bin/gorpmc/ || handle_error "Failed to rm /usr/local/bin/gorpmc/"
sudo rm /usr/local/bin/gorp || handle_error "Failed to rm /usr/local/bin/gorp"



#### Create directories & install new files

sudo mkdir -p /usr/local/bin/gorpmc/ || handle_error "Failed to mkdir /usr/local/bin/gorpmc/"
sudo mkdir /usr/local/bin/gorpmc/action/ || handle_error "Failed to mkdir /usr/local/bin/gorpmc/action/"
sudo mkdir /usr/local/bin/gorpmc/functions/ || handle_error "Failed to mkdir /usr/local/bin/gorpmc/functions/"
sudo mkdir /usr/local/bin/gorpmc/worker/ || handle_error "Failed to mkdir /usr/local/bin/gorpmc/worker/"

sudo cp /tmp/gorp/updatefiles/action/* /usr/local/bin/gorpmc/action/ || handle_error "Failed to cp /tmp/gorp/updatefiles/action/* to /usr/local/bin/gorpmc/action/"
sudo cp /tmp/gorp/updatefiles/functions/* /usr/local/bin/gorpmc/functions/ || handle_error "Failed to cp /tmp/gorp/updatefiles/action/* to /usr/local/bin/gorpmc/action/"
sudo cp /tmp/gorp/updatefiles/worker/* /usr/local/bin/gorpmc/worker/ || handle_error "Failed to cp /tmp/gorp/updatefiles/worker/* to /usr/local/bin/gorpmc/worker/"
sudo cp /tmp/gorp/updatefiles/argparse.sh /usr/local/bin/gorpmc/ || handle_error "Failed to cp /tmp/gorp/updatefiles/argparse.sh to /usr/local/bin/gorpmc/"
sudo cp /tmp/gorp/updatefiles/entry.sh /usr/local/bin/gorpmc/ || handle_error "Failed to cp /tmp/gorp/updatefiles/entry.sh to /usr/local/bin/gorpmc/"
sudo cp /tmp/gorp/updatefiles/gorp /usr/local/bin/ || handle_error "Failed to cp /tmp/gorp/updatefiles/gorp to /usr/local/bin/"
sudo cp /tmp/gorp/updatefiles/help.txt /usr/local/bin/gorpmc/ || handle_error "Failed to cp /tmp/gorp/updatefiles/help.txt to /usr/local/bin/gorpmc/"
sudo cp /tmp/gorp/updatefiles/run.sh /usr/local/bin/gorpmc/ || handle_error "Failed to cp /tmp/gorp/updatefiles/run.sh to /usr/local/bin/gorpmc/"







#### STAGE 2: HANDLE CONFIG FILES ############

#### Store current config

GAMEVER_ORIG="$(cat /usr/local/etc/gorp.conf | grep "^[^#;]" | grep -e '^GAMEVER=' | cut -d '=' -f2)"
RAM_ORIG="$(cat /usr/local/etc/gorp.conf | grep "^[^#;]" | grep -e '^RAM=' | cut -d '=' -f2)"
MAX_RAM_ORIG="$(cat /usr/local/etc/gorp.conf | grep "^[^#;]" | grep -e '^MAX_RAM=' | cut -d '=' -f2)"
HOMEDIR_ORIG="$(cat /usr/local/etc/gorp.conf | grep "^[^#;]" | grep -e '^HOMEDIR=' | cut -d '=' -f2)"
BACKUP_DEST_ORIG="$(cat /usr/local/etc/gorp.conf | grep "^[^#;]" | grep -e '^BACKUP_DEST=' | cut -d '=' -f2)"
ARCHIVE_DEST_ORIG="$(cat /usr/local/etc/gorp.conf | grep "^[^#;]" | grep -e '^ARCHIVE_DEST=' | cut -d '=' -f2)"
UPDATE_FREQUENCY_ORIG="$(cat /usr/local/etc/gorp.conf | grep "^[^#;]" | grep -e '^UPDATE_FREQUENCY=' | cut -d '=' -f2)"
TEXT_EDITOR_ORIG="$(cat /usr/local/etc/gorp.conf | grep "^[^#;]" | grep -e '^TEXT_EDITOR=' | cut -d '=' -f2)"



#### Copy new config file over

sudo rm /usr/local/etc/gorp.conf || handle_error "Failed to rm /usr/local/etc/gorp.conf "
sudo cp /tmp/gorp/updatefiles/gorp.conf /usr/local/etc/gorp.conf || handle_error "Failed to cp /tmp/gorp/updatefiles/gorp.conf to /usr/local/etc/gorp.conf"



#### Replace defaults with stored values

sudo sed -i "20s:.*:GAMEVER=$GAMEVER_ORIG:" /usr/local/etc/gorp.conf || handle_error "Failed to update GAMEVER in config"
sudo sed -i "30s:.*:RAM=$RAM_ORIG:" /usr/local/etc/gorp.conf || handle_error "Failed to update RAM in config"
sudo sed -i "40s:.*:MAX_RAM=$MAX_RAM_ORIG:" /usr/local/etc/gorp.conf || handle_error "Failed to update MAX_RAM in config"
sudo sed -i "50s:.*:HOMEDIR=$HOMEDIR_ORIG:" /usr/local/etc/gorp.conf || handle_error "Failed to update HOMEDIR in config"
sudo sed -i "60s:.*:BACKUP_DEST=$BACKUP_DEST_ORIG:" /usr/local/etc/gorp.conf || handle_error "Failed to update BACKUP_DEST in config"
sudo sed -i "70s:.*:ARCHIVE_DEST=$ARCHIVE_DEST_ORIG:" /usr/local/etc/gorp.conf || handle_error "Failed to update ARCHIVE_DEST in config"



#### New configuration key handler. For when an update adds a previously non-existent config key.

## Handle UPDATE_FREQUENCY (added in 0.6.2)
if [[ "$UPDATE_FREQUENCY_ORIG" == "" ]]; then
    sudo sed -i "80s:.*:UPDATE_FREQUENCY=0 4 * * 2:" /usr/local/etc/gorp.conf || handle_error "Failed to update UPDATE_FREQUENCY in config"
else
    sudo sed -i "80s:.*:UPDATE_FREQUENCY=$UPDATE_FREQUENCY_ORIG:" /usr/local/etc/gorp.conf || handle_error "Failed to update UPDATE_FREQUENCY in config"
fi


## Handle TEXT_EDITOR (added in 0.6.2)
if [[ "$TEXT_EDITOR_ORIG" == "" ]]; then
    sudo sed -i "90s:.*:TEXT_EDITOR=:" /usr/local/etc/gorp.conf || handle_error "Failed to update TEXT_EDITOR in config"
else
    sudo sed -i "90s:.*:TEXT_EDITOR=$TEXT_EDITOR_ORIG:" /usr/local/etc/gorp.conf || handle_error "Failed to update TEXT_EDITOR in config"
fi









#### STAGE 3: DEAL WITH RUN.SH FILES IN ALL SERVERS ############

if [[ $(ls $HOMEDIR/servers/) != "" ]]; then

    for d in "$HOMEDIR/servers/"*
    do

        SERVER=$(echo $(basename "$d"))

        if [[ -f "$HOMEDIR/servers/$SERVER/run.sh" ]]; then

            JAR_ORIG="$(cat $HOMEDIR/servers/$SERVER/run.sh | grep "^[^#;]" | grep 'CUSTOM_JAR=')"
            RAM_ORIG="$(cat $HOMEDIR/servers/$SERVER/run.sh | grep "^[^#;]" | grep 'CUSTOM_RAM=')"

            cp /tmp/gorp/updatefiles/worker/run.sh $HOMEDIR/servers/$SERVER/run.sh || handle_error "Failed to cp /tmp/gorp/updatefiles/worker/run.sh to $HOMEDIR/servers/$SERVER/run.sh"

            sed -i "25s:.*:$JAR_ORIG:" $HOMEDIR/servers/$SERVER/run.sh || handle_error "Failed to update JAR in run.sh for $SERVER"
            sed -i "34s:.*:$RAM_ORIG:" $HOMEDIR/servers/$SERVER/run.sh || handle_error "Failed to update RAM in run.sh for $SERVER"
        
        fi

    done

fi







#### WE MADE IT ############

echo "Gorp upgraded!"