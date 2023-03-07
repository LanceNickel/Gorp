#!/usr/bin/env bash

### [CREATE-WORLD WORKER] #########################################
#   Description:  Worker script that performs the new world tasks.
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
    if $ERRORS; then echo "createworld.sh: Not intended to be run directly. Exit (13)."; fi
    exit 13
fi







#### SCRIPT PARAMETERS ################

source /usr/local/bin/gorpmc/worker/i_getconfigparams.sh

SERVER=$2
NEW_WORLD=$3

OLD_WORLD=$(activeWorld "$SERVER")







####







### IF NEW_WORLD NOT SPECIFIED THEN ASK USER

if [[ "$NEW_WORLD" == "" ]]; then

        while [ true ]
        do
                read -r -p "Enter a new world name: " response

                if [[ -d "$HOMEDIR/servers/$SERVER/world-$response" ]]; then
                        if $OUTPUT; then echo "A world with this name already exists."; fi
                else
                        NEW_WORLD=$response
                        break
                fi
        done

fi







### UPDATE 'level-name' IN 'server.properties' AND START/STOP SERVER TO GENERATE WORLD FILES

if $OUTPUT; then echo "Generating new world..."; fi

sed -i "s/level-name=$OLD_WORLD/level-name=world-$NEW_WORLD/" $HOMEDIR/servers/$SERVER/server.properties

/usr/local/bin/gorpmc/action/mcstart $1 $SERVER -y > /dev/null







if $OUTPUT; then echo "New world created! Server is running."; fi