#!/usr/bin/env bash

### [DELETE WORKER] ###############################################
#   Description:  Worker script that deletes a server directory.
#   Parameters:   1: (required) Server directory name

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################



#### GUARDS ################

### KEY GUARD

if [[ "$1" != "pleasedontdothis" ]]; then
    echo "deleteserver.sh: Not intended to be run directly. Exit (13)."
    exit 13
fi



#### SCRIPT PARAMETERS ################

SERVER=$2



####



# USER CONFIRMATION GUARD

echo "You are going to DELETE a server. There is no way back."

read -r -p "Did you back up the server? [y/n] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    sleep 0.25
else
    echo "deleteserver.sh: You answered the prompt wrong! Exit (16)."
    exit 16
fi

read -r -p "Enter '$SERVER' to confirm: " response
if [[ "$response" == "$SERVER" ]]; then
    sleep 0.5
else
    echo "deleteserver.sh: You answered the prompt wrong! Exit (16)."
    exit 16
fi



# DELETE SERVER

echo "delete.sh: Deleting server..."

rm -rf $HOMEDIR/servers/$SERVER



echo "delete.sh: Server deleted."