#!/usr/bin/env bash

### [CREATE-WORLD WORKER] #########################################
#   Description:  Worker script that performs the new world tasks.
#   Parameters:   1: (required) Server directory name
#                 2: (optional) World (level) name for directory

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################

# Copyright (C) Lance Nickel 2023.
# Distributed under GNU GPL v3.
# <https://gorp.lanickel.com/license/>



#### SETUP ############

#### Globals

source /usr/local/bin/gorpmc/functions/exit.sh
source /usr/local/bin/gorpmc/functions/params.sh
source /usr/local/bin/gorpmc/functions/functions.sh



#### Key guard

if [[ "$1" == "pleasedontdothis" ]]; then
    handle_error "Script not meant to be run directly."
fi



#### Collect arguments & additional variables

SERVER=$2
NEW_WORLD=$3

CURRENT_ACTIVE_WORLD=$(get_active_world "$SERVER")







####







#### IF NEW_WORLD NOT SPECIFIED THEN ASK USER ############

if [[ "$NEW_WORLD" == "" ]]; then

        while [ true ]
        do
                read -r -p "Enter a new world name: " response

                if [[ -d "$HOMEDIR/servers/$SERVER/world-$response" ]]; then
                        echo "A world with this name already exists."
                else
                        NEW_WORLD=$response
                        break
                fi
        done

fi







#### UPDATE 'level-name' IN 'server.properties' AND START/STOP SERVER TO GENERATE WORLD FILES ##########

echo "Generating new world..."

sed -i "s/level-name=$CURRENT_ACTIVE_WORLD/level-name=world-$NEW_WORLD/" $HOMEDIR/servers/$SERVER/server.properties  || handle_error "Failed to update level-name in server.properties"
bash /usr/local/bin/gorpmc/action/mcstart $1 $SERVER -y > /dev/null || handle_error "message" || handle_error "Failed to start server"







#### WE MADE IT ############

echo "New world created! Server is running."