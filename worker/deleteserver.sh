#!/usr/bin/env bash

### [DELETE WORKER] ###############################################
#   Description:  Worker script that deletes a server directory.
#   Parameters:   1: (required) Server directory name

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

SERVER=$2







####







### USER CONFIRMATION GUARD

echo "You are going to DELETE a server. There is no way back."

read -r -p "Did you back up the server? [y/n] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    sleep 0.25
else
    handle_error "deleteserver.sh: You answered the prompt wrong!"
fi

read -r -p "Enter '$SERVER' to confirm: " response
if [[ "$response" == "$SERVER" ]]; then
    sleep 0.5
else
    handle_error "deleteserver.sh: You answered the prompt wrong!"
fi







### DELETE SERVER

rm -rf $HOMEDIR/servers/$SERVER || handle_error "Failed to rm $HOMEDIR/servers/$SERVER"







echo "Server deleted!"