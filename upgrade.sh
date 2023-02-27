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

if [[ "$1" != "pleasedontdothis" ]]; then
    echo "mcarchiveworld: Not intended to be run directly. Exit (13)."
    exit 13
fi



### ROOT GUARD

if [[ "$EUID" == 0 ]]; then
    echo "Please do not run as root or with 'sudo'. Gorp will ask for sudo rights if it needs it. Exit (10)."
    exit 10
fi



### GET SUDO PERMISSIONS

echo "To upgrade, Gorp needs sudo."
sudo whoami > /dev/null



#### SCRIPT PARAMETERS ################

source /usr/local/bin/gorpmc/worker/i_getconfigparams.sh



####



################### STAGE 1: INSTALL UPDATED SHELL SCRIPTS TO /usr/local/bin/

echo "upgrade.sh: Upgrading Gorp..."



### MAKE SCRIPT FILES EXECUTABLE

chmod +x $HOMEDIR/tmp/updatefiles/action/*
chmod +x $HOMEDIR/tmp/updatefiles/worker/*
chmod +x $HOMEDIR/tmp/updatefiles/gorp



### REMOVE CURRENT INSTALLATION

rm -rf /usr/local/bin/gorpmc/
rm /usr/local/bin/gorp



### CREATE DIRECTORIES AND RE-INSTALL GORP

mkdir -p /usr/local/bin/gorpmc/
mkdir /usr/local/bin/gorpmc/action
mkdir /usr/local/bin/gorpmc/worker

cp $HOMEDIR/tmp/updatefiles/action/* /usr/local/bin/gorpmc/action/
cp $HOMEDIR/tmp/updatefiles/worker/* /usr/local/bin/gorpmc/worker/
cp $HOMEDIR/tmp/updatefiles/help.txt /usr/local/bin/gorpmc/
cp $HOMEDIR/tmp/updatefiles/gorp /usr/local/bin/



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









### DEAL WITH THE RUN SCRIPTS IN ALL SERVERS (if required)

if [[ $(ls $HOMEDIR/servers/) != "" ]]; then

    for d in "$HOMEDIR/servers/"*
    do

        SERVER=$(echo $(basename "$d"))

        JAR_ORIG="$(cat $HOMEDIR/servers/$SERVER/run.sh | grep "^[^#;]" | grep 'JAR=')"
        RAM_ORIG="$(cat $HOMEDIR/servers/$SERVER/run.sh | grep "^[^#;]" | grep 'RAM=')"

        cp $HOMEDIR/tmp/updatefiles/worker/run.sh $HOMEDIR/servers/$SERVER/run.sh

        sed -i "22s:.*:$JAR_ORIG:" $HOMEDIR/servers/$SERVER/run.sh
        sed -i "31s:.*:$RAM_ORIG:" $HOMEDIR/servers/$SERVER/run.sh

    done

fi



echo "upgrade.sh: Gorp upgrade complete."