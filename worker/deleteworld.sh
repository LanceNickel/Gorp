#!/usr/bin/env bash

### [DELETE-WORLD WORKER] #########################################
#   Description:  Worker script that performs the world delete.
#   Parameters:   1: (required) Server directory name
#                 2: (optional) World (level) name for directory

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
    if $ERRORS; then echo "deleteworld.sh: Not intended to be run directly. Exit (13)."; fi
    exit 13
fi







#### SCRIPT PARAMETERS ################

source /usr/local/bin/gorpmc/worker/i_getconfigparams.sh

SERVER=$2
WORLD_TO_DELETE=$3

OPTIONS=$(worldOptions "$SERVER")







####







### IF WORLD_TO_DELETE NOT SPECIFIED, ASK USER

if [[ "$WORLD_TO_DELETE" == "" ]]; then
    while [ true ]
    do
        if $OUTPUT; then echo -e "Options:\n$OPTIONS"; fi

        read -r -p "Please enter a world to delete: " response

        TEST=$(echo $OPTIONS | grep -w $response)

        if [[ "$TEST" != "" ]]; then
            WORLD_TO_DELETE=$response
            break
        else
            if $OUTPUT; then echo -e "\nSpecified world does not exist.\n"; fi
        fi
    done
fi







### USER CONFIRMATION GUARDS

if $OUTPUT; then echo "You are about to delete a world named '$WORLD_TO_DELETE' in the '$SERVER' server instance."; fi

read -r -p "Did you back up the world? [y/n] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    sleep 0.005
else
    if $ERRORS; then echo "deleteworld.sh: You answered the prompt wrong! Exit (16)."; fi
    exit 16
fi

read -r -p "Enter '$WORLD_TO_DELETE' to confirm: " response
if [[ "$response" == "$WORLD_TO_DELETE" ]]; then
    sleep 0.5
else
    if $ERRORS; then echo "deleteworld.sh: You answered the prompt wrong! Exit (16)."; fi
    exit 16
fi







### DELETE THE WORLD

rm -rf $HOMEDIR/servers/$SERVER/world-$WORLD_TO_DELETE
rm -rf $HOMEDIR/servers/$SERVER/world-${WORLD_TO_DELETE}_nether
rm -rf $HOMEDIR/servers/$SERVER/world-${WORLD_TO_DELETE}_the_end







if $OUTPUT; then echo "World deleted!"; fi