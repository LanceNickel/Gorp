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

GAMEVER_ORIG="$(cat /usr/local/etc/gorp.conf | grep "^[^#;]" | grep 'GAMEVER=' | cut -d '=' -f2)"
RAM_ORIG="$(cat /usr/local/etc/gorp.conf | grep "^[^#;]" | grep 'RAM=' | cut -d '=' -f2)"
HOMEDIR_ORIG="$(cat /usr/local/etc/gorp.conf | grep "^[^#;]" | grep 'HOMEDIR=' | cut -d '=' -f2)"
BACKUP_DEST_ORIG="$(cat /usr/local/etc/gorp.conf | grep "^[^#;]" | grep 'BACKUP_DEST=' | cut -d '=' -f2)"
ARCHIVE_DEST_ORIG="$(cat /usr/local/etc/gorp.conf | grep "^[^#;]" | grep 'ARCHIVE_DEST=' | cut -d '=' -f2)"



#### Copy new config file over

sudo rm /usr/local/etc/gorp.conf || handle_error "Failed to rm /usr/local/etc/gorp.conf "
sudo cp /tmp/gorp/updatefiles/gorp.conf /usr/local/etc/gorp.conf || handle_error "Failed to cp /tmp/gorp/updatefiles/gorp.conf to /usr/local/etc/gorp.conf"



#### Replace defaults with stored values

sudo sed -i "20s:.*:GAMEVER=$GAMEVER_ORIG:" /usr/local/etc/gorp.conf || handle_error "Failed to update GAMEVER in config"
sudo sed -i "30s:.*:RAM=$RAM_ORIG:" /usr/local/etc/gorp.conf || handle_error "Failed to update RAM in config"
sudo sed -i "40s:.*:HOMEDIR=$HOMEDIR_ORIG:" /usr/local/etc/gorp.conf || handle_error "Failed to update HOMEDIR in config"
sudo sed -i "50s:.*:BACKUP_DEST=$BACKUP_DEST_ORIG:" /usr/local/etc/gorp.conf || handle_error "Failed to update BACKUP_DEST in config"
sudo sed -i "60s:.*:ARCHIVE_DEST=$ARCHIVE_DEST_ORIG:" /usr/local/etc/gorp.conf || handle_error "Failed to update ARCHIVE_DEST in config"







#### STAGE 3: DEAL WITH RUN.SH FILES IN ALL SERVERS ############

if [[ $(ls $HOMEDIR/servers/) != "" ]]; then

    for d in "$HOMEDIR/servers/"*
    do

        SERVER=$(echo $(basename "$d"))

        JAR_ORIG="$(cat $HOMEDIR/servers/$SERVER/run.sh | grep "^[^#;]" | grep 'JAR=')"
        RAM_ORIG="$(cat $HOMEDIR/servers/$SERVER/run.sh | grep "^[^#;]" | grep 'RAM=')"

        cp /tmp/gorp/updatefiles/worker/run.sh $HOMEDIR/servers/$SERVER/run.sh || handle_error "Failed to cp /tmp/gorp/updatefiles/worker/run.sh to $HOMEDIR/servers/$SERVER/run.sh"

        sed -i "21s:.*:$JAR_ORIG:" $HOMEDIR/servers/$SERVER/run.sh || handle_error "Failed to update JAR in run.sh for $SERVER"
        sed -i "30s:.*:$RAM_ORIG:" $HOMEDIR/servers/$SERVER/run.sh || handle_error "Failed to update RAM in run.sh for $SERVER"

    done

fi







#### WE MADE IT ############

echo "Gorp upgraded!"