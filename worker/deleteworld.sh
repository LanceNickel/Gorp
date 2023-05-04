#!/usr/bin/env bash

### [DELETE-WORLD WORKER] #########################################
#   Description:  Worker script that performs the world delete.
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

if [[ "$1" != "pleasedontdothis" ]]; then
    handle_error "Script not meant to be run directly."
fi



#### Collect arguments & additional variables

SERVER=$2
WORLD_TO_DELETE=$3

OPTIONS=$(list_worlds "$SERVER")







####







#### IF WORLD_TO_DELETE NOT SPECIFIED, ASK USER ############

if [[ "$WORLD_TO_DELETE" == "" ]]; then
    while [ true ]
    do
        echo -e "Options:\n$OPTIONS"

        read -r -p "Please enter a world to delete: " response

        TEST=$(echo $OPTIONS | grep -w $response)

        if [[ "$TEST" != "" ]]; then
            WORLD_TO_DELETE=$response
            break
        else
            echo -e "\nSpecified world does not exist.\n"
        fi
    done
fi







#### USER CONFIRMATION ############

echo "You are about to delete a world named '$WORLD_TO_DELETE' in the '$SERVER' server instance."

read -r -p "Did you back up the world? [y/n] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    sleep 0.005
else
    echo "You answered the prompt wrong!"
fi

read -r -p "Enter '$WORLD_TO_DELETE' to confirm: " response
if [[ "$response" == "$WORLD_TO_DELETE" ]]; then
    sleep 0.005
else
    echo "You answered the prompt wrong!"
fi







#### DELETE THE WORLD ############

rm -rf $HOMEDIR/servers/$SERVER/world-$WORLD_TO_DELETE || handle_error "Failed to delete overworld files"
rm -rf $HOMEDIR/servers/$SERVER/world-${WORLD_TO_DELETE}_nether || handle_error "Failed to delete nether files"
rm -rf $HOMEDIR/servers/$SERVER/world-${WORLD_TO_DELETE}_the_end || handle_error "Failed to delete end files"







#### WE MADE IT ############

echo "World deleted!"