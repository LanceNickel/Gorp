#!/usr/bin/env bash

### [SWITCH-WORLD WORKER] #########################################
#   Description:  Worker script that performs the world switch.
#   Parameters:   1: (required) Server directory name

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################



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
    if $ERRORS; then echo "switchworld.sh: Not intended to be run directly. Exit (13)."; fi
    exit 13
fi







#### SCRIPT PARAMETERS ################

source /usr/local/bin/gorpmc/worker/i_getconfigparams.sh

SERVER=$2
SWITCH_TO=$3

OPTIONS=$(worldOptions "$SERVER")
CURRENT_WORLD=$(activeWorld "$SERVER")







####







### GET USER INPUT (if user did not specify a world)

if [[ "$SWITCH_TO" == "" ]]; then

    while [ true ]; do
        if $OUTPUT; then echo -e "Options:\n$OPTIONS"; fi

        read -r -p "Please enter a world to switch to: " response

        TEST=$(echo $OPTIONS | grep -w $response)

        if [[ "$TEST" != "" ]]; then
            SWITCH_TO=$response
            break
        else
            if $OUTPUT; then echo -e "\nSpecified world does not exist.\n"; fi
        fi
    done

fi







### SWITCH THE VALUE IN 'server.properties'

sed -i "s/level-name=$CURRENT_WORLD/level-name=world-$SWITCH_TO/" $HOMEDIR/servers/$SERVER/server.properties







if $OUTPUT; then echo "World switched!"; fi