#!/usr/bin/env bash

### [RESET-WORLD WORKER] ##########################################
#   Description:  Worker script that performs the world reset.
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

#### Key guard

if [[ "$1" == "pleasedontdothis" ]]; then
    handle_error "Script not meant to be run directly."
fi



#### Globals

source /usr/local/bin/gorpmc/functions/exit.sh
source /usr/local/bin/gorpmc/functions/params.sh
source /usr/local/bin/gorpmc/functions/functions.sh



#### Collect arguments & additional variables

SERVER=$2
WORLD_TO_RESET=$(get_active_world "$SERVER")
RUNNING=$(is_server_running "$SERVER")







####







#### USER CONFIRMATION ############

echo "You are about to reset the world named '$WORLD_TO_RESET' in the '$SERVER' server instance."

read -r -p "Did you back up the world/don't care about it? [y/n] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "Resetting world..."
else
    handle_error "You answered the prompt wrong!"
fi







#### IF SERVER RUNNING, STOP ############

if [[ "$RUNNING" == "true" ]]; then
    echo "Stopping server..."
    bash /usr/local/bin/gorpmc/action/mcstop $1 $SERVER now > /dev/null || handle_error "Failed to stop server"
fi







#### DELETE WORLD ############

rm -rf $HOMEDIR/servers/$SERVER/$WORLD_TO_RESET || handle_error "Failed to delete overworld files"
rm -rf $HOMEDIR/servers/$SERVER/${WORLD_TO_RESET}_nether || handle_error "Failed to delete nether files"
rm -rf $HOMEDIR/servers/$SERVER/${WORLD_TO_RESET}_the_end || handle_error "Failed to delete end files"







#### START SERVER TO GENERATE NEW WORLD ############

echo "Generating new world..."
bash /usr/local/bin/gorpmc/action/mcstart $1 $SERVER -y > /dev/null || handle_error "Failed to start server"







#### WE MADE IT ############

echo "World reset! Server is running."