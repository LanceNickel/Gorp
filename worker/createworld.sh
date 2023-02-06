#!/usr/bin/env bash

### [CREATE-WORLD WORKER] #########################################
#   Description:  Worker script that performs the new world tasks.
#   Parameters:   1: (required) Server directory name
#                 2: (required) World (level) name for directory

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################



# PERMISSIONS GUARD

if [[ "$EUID" != 0 ]]; then
        echo "createworld.sh: Insufficient privilege. Exiting."
        exit
fi



# SCRIPT VARIABLES

SERVER=$1
NEW_WORLD=$2

OLD_WORLD=$(cat /minecraft/servers/$SERVER/server.properties | grep 'level-name=' | cut -d '=' -f2)



####



# UPDATE 'level-name' IN 'server.properties' TO CREATE NEW WORLD ON START

sed -i "s/level-name=$OLD_WORLD/level-name=world-$NEW_WORLD/" /minecraft/servers/$SERVER/server.properties



echo "createworld.sh: Your server configuration has been updated. Run the server to create the new world."