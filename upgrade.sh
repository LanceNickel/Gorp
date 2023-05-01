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



#### GUARDS ################

### KEY GUARD

if [[ "$1" == "pleasedontdothis" ]]; then
    handle_error "Script not meant to be run directly."
fi







### ROOT GUARD

if [[ "$EUID" == 0 ]]; then
    handle_error "upgrade.sh: Please do not run as root or with 'sudo'. Gorp will ask for sudo rights if it needs it."
fi







#### SCRIPT PARAMETERS ################







####







################### STAGE 1: INSTALL UPDATED SHELL SCRIPTS TO /usr/local/bin/

echo "Upgrading Gorp..."; fi







### MAKE SCRIPT FILES EXECUTABLE

chmod +x $HOMEDIR/tmp/updatefiles/action/* || handle_error "Failed to +x actions"
chmod +x $HOMEDIR/tmp/updatefiles/worker/* || handle_error "Failed to +x workers"
chmod +x $HOMEDIR/tmp/updatefiles/gorp || handle_error "Failed to +x gorp"







### REMOVE CURRENT INSTALLATION

sudo rm -rf /usr/local/bin/gorpmc/ || handle_error "Failed to rm /usr/local/bin/gorpmc/"
sudo rm /usr/local/bin/gorp || handle_error "Failed to rm /usr/local/bin/gorp"







### CREATE DIRECTORIES AND RE-INSTALL GORP

sudo mkdir -p /usr/local/bin/gorpmc/ || handle_error "Failed to mkdir /usr/local/bin/gorpmc/"
sudo mkdir /usr/local/bin/gorpmc/action/ || handle_error "Failed to mkdir /usr/local/bin/gorpmc/action/"
sudo mkdir /usr/local/bin/gorpmc/worker/ || handle_error "Failed to mkdir /usr/local/bin/gorpmc/worker/"

sudo cp $HOMEDIR/tmp/updatefiles/action/* /usr/local/bin/gorpmc/action/ || handle_error "Failed to cp $HOMEDIR/tmp/updatefiles/action/* to /usr/local/bin/gorpmc/action/"
sudo cp $HOMEDIR/tmp/updatefiles/worker/* /usr/local/bin/gorpmc/worker/ || handle_error "Failed to cp $HOMEDIR/tmp/updatefiles/worker/* to /usr/local/bin/gorpmc/worker/"
sudo cp $HOMEDIR/tmp/updatefiles/help.txt /usr/local/bin/gorpmc/ || handle_error "Failed to cp $HOMEDIR/tmp/updatefiles/help.txt to /usr/local/bin/gorpmc/"
sudo cp $HOMEDIR/tmp/updatefiles/gorp /usr/local/bin/ || handle_error "Failed to cp $HOMEDIR/tmp/updatefiles/gorp to /usr/local/bin/"







### DEAL WITH THE CONFIGURATION FILE

# Store currently set values in config

GAMEVER_ORIG="$(cat /usr/local/etc/gorp.conf | grep "^[^#;]" | grep 'GAMEVER=' | cut -d '=' -f2)"
RAM_ORIG="$(cat /usr/local/etc/gorp.conf | grep "^[^#;]" | grep 'RAM=' | cut -d '=' -f2)"
HOMEDIR_ORIG="$(cat /usr/local/etc/gorp.conf | grep "^[^#;]" | grep 'HOMEDIR=' | cut -d '=' -f2)"
BACKUP_DEST_ORIG="$(cat /usr/local/etc/gorp.conf | grep "^[^#;]" | grep 'BACKUP_DEST=' | cut -d '=' -f2)"
ARCHIVE_DEST_ORIG="$(cat /usr/local/etc/gorp.conf | grep "^[^#;]" | grep 'ARCHIVE_DEST=' | cut -d '=' -f2)"



# Copy the new config over

sudo rm /usr/local/etc/gorp.conf || handle_error "Failed to rm /usr/local/etc/gorp.conf "
sudo cp $HOMEDIR/tmp/updatefiles/gorp.conf /usr/local/etc/gorp.conf || handle_error "Failed to cp $HOMEDIR/tmp/updatefiles/gorp.conf to /usr/local/etc/gorp.conf"



# Deal with the options

sudo sed -i "20s:.*:GAMEVER=$GAMEVER_ORIG:" /usr/local/etc/gorp.conf || handle_error "Failed to update GAMEVER in config"
sudo sed -i "30s:.*:RAM=$RAM_ORIG:" /usr/local/etc/gorp.conf || handle_error "Failed to update RAM in config"
sudo sed -i "40s:.*:HOMEDIR=$HOMEDIR_ORIG:" /usr/local/etc/gorp.conf || handle_error "Failed to update HOMEDIR in config"
sudo sed -i "50s:.*:BACKUP_DEST=$BACKUP_DEST_ORIG:" /usr/local/etc/gorp.conf || handle_error "Failed to update BACKUP_DEST in config"
sudo sed -i "60s:.*:ARCHIVE_DEST=$ARCHIVE_DEST_ORIG:" /usr/local/etc/gorp.conf || handle_error "Failed to update ARCHIVE_DEST in config"







sleep 1







### DEAL WITH THE RUN SCRIPTS IN ALL SERVERS (if required)

if [[ $(ls $HOMEDIR/servers/) != "" ]]; then

    for d in "$HOMEDIR/servers/"*
    do

        SERVER=$(echo $(basename "$d"))

        JAR_ORIG="$(cat $HOMEDIR/servers/$SERVER/run.sh | grep "^[^#;]" | grep 'JAR=')"
        RAM_ORIG="$(cat $HOMEDIR/servers/$SERVER/run.sh | grep "^[^#;]" | grep 'RAM=')"

        cp $HOMEDIR/tmp/updatefiles/worker/run.sh $HOMEDIR/servers/$SERVER/run.sh || handle_error "Failed to cp $HOMEDIR/tmp/updatefiles/worker/run.sh to $HOMEDIR/servers/$SERVER/run.sh"

        sed -i "21s:.*:$JAR_ORIG:" $HOMEDIR/servers/$SERVER/run.sh || handle_error "Failed to update JAR in run.sh for $SERVER"
        sed -i "30s:.*:$RAM_ORIG:" $HOMEDIR/servers/$SERVER/run.sh || handle_error "Failed to update RAM in run.sh for $SERVER"

    done

fi







echo "Gorp upgraded!"; fi