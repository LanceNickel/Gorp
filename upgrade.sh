#!/usr/bin/env bash

### [GORP UPGRADE WORKER] #########################################
#   Description:  Worker script that performs the upgrade tasks.
#   Parameters:   None

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################



#### GUARDS ################

### KEY GUARD

if [[ "$1" == "pleasedontdothis" ]]; then
    OUTPUT=true
    ERRORS=true

elif [[ "$1" == "pleaseshutup" ]]; then
    OUTPUT=false
    ERRORS=true

elif [[ "$1" == "pleasebesilent" ]]; then
    OUTPUT=false
    ERRORS=false

else
    if $ERRORS; then echo "SCRIPTNAME: Not intended to be run directly. Exit (13)."; fi
    exit 13
fi







### ROOT GUARD

if [[ "$EUID" == 0 ]]; then
    if $ERRORS; then echo "upgrade.sh: Please do not run as root or with 'sudo'. Gorp will ask for sudo rights if it needs it. Exit (10)."; fi
    exit 10
fi







#### SCRIPT PARAMETERS ################

source /usr/local/bin/gorpmc/worker/i_getconfigparams.sh







####







################### STAGE 1: INSTALL UPDATED SHELL SCRIPTS TO /usr/local/bin/

if $OUTPUT; then echo "Upgrading Gorp..."; fi







### MAKE SCRIPT FILES EXECUTABLE

chmod +x $HOMEDIR/tmp/updatefiles/action/*
chmod +x $HOMEDIR/tmp/updatefiles/worker/*
chmod +x $HOMEDIR/tmp/updatefiles/gorp







### REMOVE CURRENT INSTALLATION

sudo rm -rf /usr/local/bin/gorpmc/
sudo rm /usr/local/bin/gorp







### CREATE DIRECTORIES AND RE-INSTALL GORP

sudo mkdir -p /usr/local/bin/gorpmc/
sudo mkdir /usr/local/bin/gorpmc/action
sudo mkdir /usr/local/bin/gorpmc/worker

sudo cp $HOMEDIR/tmp/updatefiles/action/* /usr/local/bin/gorpmc/action/
sudo cp $HOMEDIR/tmp/updatefiles/worker/* /usr/local/bin/gorpmc/worker/
sudo cp $HOMEDIR/tmp/updatefiles/help.txt /usr/local/bin/gorpmc/
sudo cp $HOMEDIR/tmp/updatefiles/gorp /usr/local/bin/






sleep 1







### DEAL WITH THE CONFIGURATION FILE

# Store currently set values in config

GAMEVER_ORIG="$(cat /usr/local/etc/gorp.conf | grep "^[^#;]" | grep 'GAMEVER=' | cut -d '=' -f2)"
RAM_ORIG="$(cat /usr/local/etc/gorp.conf | grep "^[^#;]" | grep 'RAM=' | cut -d '=' -f2)"
HOMEDIR_ORIG="$(cat /usr/local/etc/gorp.conf | grep "^[^#;]" | grep 'HOMEDIR=' | cut -d '=' -f2)"
BACKUP_DEST_ORIG="$(cat /usr/local/etc/gorp.conf | grep "^[^#;]" | grep 'BACKUP_DEST=' | cut -d '=' -f2)"
ARCHIVE_DEST_ORIG="$(cat /usr/local/etc/gorp.conf | grep "^[^#;]" | grep 'ARCHIVE_DEST=' | cut -d '=' -f2)"



# Copy the new config over

sudo rm /usr/local/etc/gorp.conf
sudo cp $HOMEDIR/tmp/updatefiles/gorp.conf /usr/local/etc/gorp.conf



# Deal with the options

sudo sed -i "20s:.*:GAMEVER=$GAMEVER_ORIG:" /usr/local/etc/gorp.conf
sudo sed -i "30s:.*:RAM=$RAM_ORIG:" /usr/local/etc/gorp.conf
sudo sed -i "40s:.*:HOMEDIR=$HOMEDIR_ORIG:" /usr/local/etc/gorp.conf
sudo sed -i "50s:.*:BACKUP_DEST=$BACKUP_DEST_ORIG:" /usr/local/etc/gorp.conf
sudo sed -i "60s:.*:ARCHIVE_DEST=$BACKUP_DEST_ORIG:" /usr/local/etc/gorp.conf







sleep 1







### DEAL WITH THE RUN SCRIPTS IN ALL SERVERS (if required)

if [[ $(ls $HOMEDIR/servers/) != "" ]]; then

    for d in "$HOMEDIR/servers/"*
    do

        SERVER=$(echo $(basename "$d"))

        JAR_ORIG="$(cat $HOMEDIR/servers/$SERVER/run.sh | grep "^[^#;]" | grep 'JAR=')"
        RAM_ORIG="$(cat $HOMEDIR/servers/$SERVER/run.sh | grep "^[^#;]" | grep 'RAM=')"

        cp $HOMEDIR/tmp/updatefiles/worker/run.sh $HOMEDIR/servers/$SERVER/run.sh

        sed -i "21s:.*:$JAR_ORIG:" $HOMEDIR/servers/$SERVER/run.sh
        sed -i "30s:.*:$RAM_ORIG:" $HOMEDIR/servers/$SERVER/run.sh

    done

fi







if $OUTPUT; then echo "Gorp upgraded!"; fi