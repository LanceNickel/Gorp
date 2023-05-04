#!/usr/bin/env bash

### [SWITCH-WORLD WORKER] #########################################
#   Description:  Worker script that performs the world switch.
#   Parameters:   1: (required) Server directory name

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

SERVER=$2
SWITCH_TO=$3

OPTIONS=$(list_worlds "$SERVER")
CURRENT_WORLD=$(get_active_world "$SERVER")







####







#### GET USER INPUT (if they didn't specify a world) ############

if [[ "$SWITCH_TO" == "" ]]; then

    while [ true ]; do
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







#### SWITCH VALUE IN SERVER PROPERTIES ############

sed -i "s/level-name=world-$CURRENT_WORLD/level-name=world-$SWITCH_TO/" $HOMEDIR/servers/$SERVER/server.properties || handle_error "Failed to update level-name in server.properties"







#### WE MADE IT ############

echo "World switched!"