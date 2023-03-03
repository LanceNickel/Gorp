#!/usr/bin/env bash

### [GORP HOMEDIR MOVE WORKER] ####################################
#   Description:  Action script to setup Gorp update worker.
#   Parameters:   (required) Absolute path to new home directory

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################



#### GUARDS ################

### KEY GUARD

if [[ "$1" != "pleasedontdothis" ]]; then
    echo "movehome.sh: Not intended to be run directly. Exit (13)."
    exit 13
fi



#### SCRIPT PARAMETERS ################

source /usr/local/bin/gorpmc/worker/i_getconfigparams.sh

NEW_HOMEDIR=$2



####



### ATTEMPT TO CREATE DESTINATION

mkdir -p $NEW_HOMEDIR/ > /dev/null

# Check for errors (rt-guard)
if [[ "$?" != "0" ]]; then
    echo "movehome.sh: Failed to create destination directory. Check permissions. Exit (23)."
    exit 23
fi



### COPY THE FILES OVER

echo "Copying files to new home..."

cp -r $HOMEDIR/* $NEW_HOMEDIR/

# Check for errors (rt-guard)
if [[ "$?" != "0" ]]; then
    echo "movehome.sh: Failed to copy files. Exit (24)."
    exit 24
fi



### UPDATE CONFIGURATION AND JAR FILE

sudo sed -i "40s:.*:HOMEDIR=$NEW_HOMEDIR:" /usr/local/etc/gorp.conf
sed -i "s:$HOMEDIR:$NEW_HOMEDIR:" $NEW_HOMEDIR/jars/latest

# Validate these
source /usr/local/bin/gorpmc/worker/i_getconfigparams.sh

if [[ "$HOMEDIR" != "$NEW_HOMEDIR" ]]; then
    echo "movehome.sh: Configuration update failed. Please manually update HOMEDIR to $NEW_HOMEDIR in /usr/local/etc/gorp.conf. Exit (17)."
    exit 17
fi

if [[ "$(grep "$HOMEDIR" $HOMEDIR/jars/latest)" == "" ]]; then
    echo "movehome.sh: Configuration update failed. Please manuall update the directory in $HOMEDIR/jars/latest. Exit (17)"
    exit 17
fi



echo "Gorp home directory moved!"