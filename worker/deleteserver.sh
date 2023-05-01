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
    OUTPUT=true
    ERRORS=true

elif [[ "$1" == "pleaseshutup" ]]; then
    OUTPUT=false
    ERRORS=true

elif [[ "$1" == "pleasebesilent" ]]; then
    OUTPUT=false
    ERRORS=false

else
    if $ERRORS; then echo "deleteserver.sh: Not intended to be run directly. Exit (13)."; fi
    exit 13
fi







#### SCRIPT PARAMETERS ################

source /usr/local/bin/gorpmc/worker/i_getconfigparams.sh

SERVER=$2







####







### USER CONFIRMATION GUARD

if $OUTPUT; then echo "You are going to DELETE a server. There is no way back."; fi

read -r -p "Did you back up the server? [y/n] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    sleep 0.25
else
    if $ERRORS; then echo "deleteserver.sh: You answered the prompt wrong! Exit (16)."; fi
    exit 16
fi

read -r -p "Enter '$SERVER' to confirm: " response
if [[ "$response" == "$SERVER" ]]; then
    sleep 0.5
else
    if $ERRORS; then echo "deleteserver.sh: You answered the prompt wrong! Exit (16)."; fi
    exit 16
fi







### DELETE SERVER

rm -rf $HOMEDIR/servers/$SERVER







if $OUTPUT; then echo "Server deleted!"; fi