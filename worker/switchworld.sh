#!/usr/bin/env bash

### [SWITCH-WORLD WORKER] #########################################
#   Description:  Worker script that performs the world switch.
#   Parameters:   1: (required) Server directory name

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################



# PERMISSIONS GUARD

if [[ "$EUID" != 0 ]]; then
        echo "switchworld.sh: Insufficient privilege. Exiting."
        exit
fi



# SCRIPT VARIABLES

SERVER=$1
SWITCH_TO=$2

OPTIONS=$(ls /minecraft/servers/$SERVER/ | grep '_nether' | cut -d '-' -f2 | cut -d '_' -f1)
CURRENT_WORLD=$(cat /minecraft/servers/$SERVER/server.properties | grep 'level-name=' | cut -d '=' -f2)



####



# GET USER INPUT (if user did not specify a world)

if [ "$SWITCH_TO" == "" ]; then

    while [ true ]
    do
        echo -e "Options:\n$OPTIONS"

        read -r -p "Please enter a world to switch to: " response

        TEST=$(echo $OPTIONS | grep -w $response)

        if [[ "$TEST" != "" ]]; then
            SWITCH_TO=$response
            break
        else
            echo -e "\nSpecified world does not exist.\n"
        fi
    done

fi



# SWITCH THE VALUE IN 'server.properties'

sed -i "s/level-name=$CURRENT_WORLD/level-name=world-$SWITCH_TO/" /minecraft/servers/$SERVER/server.properties



echo "switchworld.sh: World switched."