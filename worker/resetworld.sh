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



#### GUARDS ################

### KEY GUARD

if [[ "$1" == "pleasedontdothis" ]]; then
    handle_error "Script not meant to be run directly."
fi







#### SCRIPT PARAMETERS ################

SERVER=$2
WORLD_TO_RESET=$(activeWorld "$SERVER")

# Is the server running?

if [[ $(screen -ls | grep "$SERVER")  != "" ]]; then
    RUNNING=true
else
    RUNNING=false
fi







####







### USER CONFIRMATION GUARDS

if $OUTPUT; then echo "You are about to reset the world named '$WORLD_TO_RESET' in the '$SERVER' server instance."; fi

read -r -p "Did you back up the world/don't care about it? [y/n] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    if $OUTPUT; then echo "Resetting world..."; fi
else
    if $ERRORS; then echo "resetworld.sh: You answered the prompt wrong! Exit (16)."; fi
    exit 16
fi







### STOP SERVER (if already running)

if [[ $RUNNING = true ]]; then
    if $OUTPUT; then echo "Stopping server..."; fi
    /usr/local/bin/gorpmc/action/mcstop $1 $SERVER -n > /dev/null
fi







### DELETE THE WORLD

if $OUTPUT; then echo "Regenerating $WORLD_TO_RESET..."; fi

rm -rf $HOMEDIR/servers/$SERVER/$WORLD_TO_RESET
rm -rf $HOMEDIR/servers/$SERVER/${WORLD_TO_RESET}_nether
rm -rf $HOMEDIR/servers/$SERVER/${WORLD_TO_RESET}_the_end







### START SERVER (to generate world)

/usr/local/bin/gorpmc/action/mcstart $1 $SERVER -y > /dev/null







if $OUTPUT; then echo "World reset! Server is running."; fi