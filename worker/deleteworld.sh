#!/usr/bin/env bash

### [DELETE-WORLD WORKER] #########################################
#   Description:  Worker script that performs the world delete.
#   Parameters:   1: (required) Server directory name
#                 2: (required) World (level) name for directory

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################



# PERMISSIONS GUARD

if [[ "$EUID" != 0 ]]; then
        echo "deleteworld.sh: Insufficient privilege. Exiting."
        exit
fi



# SCRIPT VARIABLES

SERVER=$1
WORLD_TO_DELETE=$2



####



# USER CONFIRMATION GUARDS

echo "You are going to DELETE a world in the '$SERVER' server instance. There is no way back."

read -r -p "Did you back up the world? [y/n] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    sleep 0.25
else
    echo "PLEASE BACK UP YOUR WORLD FILES! Run 'mcbackup $SERVER' to take a back up first."
    exit
fi

read -r -p "Enter '$WORLD_TO_DELETE' to confirm: " response
if [[ "$response" == "$WORLD_TO_DELETE" ]]; then
    sleep 0.5
else
    echo "Incorrect response. Exiting."
    exit
fi



# DELETE THE WORLD

rm -rf /minecraft/servers/$SERVER/world-$WORLD_TO_DELETE
rm -rf /minecraft/servers/$SERVER/world-${WORLD_TO_DELETE}_nether
rm -rf /minecraft/servers/$SERVER/world-${WORLD_TO_DELETE}_the_end



echo "deleteworld.sh: World deleted."