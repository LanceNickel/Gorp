#!/usr/bin/env bash

### [GORP HOMEDIR MOVE WORKER] ####################################
#   Description:  Action script to setup Gorp update worker.
#   Parameters:   (required) Absolute path to new home directory

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







#### SCRIPT PARAMETERS ################

NEW_HOMEDIR=$2







####







### ATTEMPT TO CREATE DESTINATION

mkdir -p $NEW_HOMEDIR/ > /dev/null



# Check for errors (rt-guard)
if [[ "$?" != "0" ]]; then
    handle_error "Failed to create destination directory. Check permissions."
fi







### COPY THE FILES OVER

echo "Copying files to new home..."

cp -r $HOMEDIR/* $NEW_HOMEDIR/



# Check for errors (rt-guard)
if [[ "$?" != "0" ]]; then
    handle_error "Failed to copy files."
fi







### UPDATE CONFIGURATION AND JAR FILE

sudo sed -i "40s:.*:HOMEDIR=$NEW_HOMEDIR:" /usr/local/etc/gorp.conf
sed -i "s:$HOMEDIR:$NEW_HOMEDIR:" $NEW_HOMEDIR/jars/latest



# Validate these
source /usr/local/bin/gorpmc/worker/i_getconfigparams.sh

if [[ "$HOMEDIR" != "$NEW_HOMEDIR" ]]; then
    handle_error "Configuration update failed. Please manually update HOMEDIR to $NEW_HOMEDIR in /usr/local/etc/gorp.conf."
fi

if [[ "$(grep "$HOMEDIR" $HOMEDIR/jars/latest)" == "" ]]; then
    handle_error "Configuration update failed. Please manuall update the directory in $HOMEDIR/jars/latest"
fi







echo "Gorp home directory moved!"