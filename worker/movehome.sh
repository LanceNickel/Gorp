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

NEW_HOMEDIR=$2







####







#### MOVE THE FILES ############

#### Create new homedir

mkdir -p $NEW_HOMEDIR/ > /dev/null || handle_error "Failed to make new home directory."



#### Copy current homedir to new homedir

echo "Copying files to new home..."

cp -r $HOMEDIR/* $NEW_HOMEDIR/ || handle_error "Failed to copy homedir to new location."







#### UPDATE CONFIGS ############

sudo sed -i "40s:.*:HOMEDIR=$NEW_HOMEDIR:" /usr/local/etc/gorp.conf || handle_error "Failed to update HOMEDIR in config file."
sed -i "s:$HOMEDIR:$NEW_HOMEDIR:" $NEW_HOMEDIR/jars/latest || handle_error "Failed to update homedir path in latest JAR file."



#### Re-. the params and make sure they're updated

. /usr/local/bin/gorpmc/functions/params.sh

if [[ "$HOMEDIR" != "$NEW_HOMEDIR" ]]; then
    handle_error "Configuration update failed. Please manually update HOMEDIR to $NEW_HOMEDIR in /usr/local/etc/gorp.conf."
fi

if [[ "$(grep "$HOMEDIR" $HOMEDIR/jars/latest)" == "" ]]; then
    handle_error "Configuration update failed. Please manually update the directory in $HOMEDIR/jars/latest."
fi







#### WE MADE IT ############

echo "Gorp home directory moved!"