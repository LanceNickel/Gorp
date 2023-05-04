#!/usr/bin/env bash

### [IN-GAME WARNING WORKER] #######################################
#   Description:  Worker script that warns players via server chat.
#   Parameters:   1: (required) Server directory name
#                 2: (required) <stop, restart, power>

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
ACTION=$3







####







#### SEND WARNING MESSAGE ############

echo "Giving a very polite heads up :) ..."

if [[ "$ACTION" == "power" ]]; then
        screen -S $SERVER -X stuff "say ATTENTION: Due to a power outage, this server must be shut down.\n" || handle_error "Failed to stuff into $SERVER"
        sleep 0.25
        screen -S $SERVER -X stuff "say ATTENTION: This server will shut down in 30 seconds.\n" || handle_error "Failed to stuff into $SERVER"
else
        screen -S $SERVER -X stuff "say ATTENTION: This server will $ACTION in 30 seconds.\n" || handle_error "Failed to stuff into $SERVER"
fi







#### WAIT 30 SECONDS & SHOW COUNTDOWN ############

I=0

while [ true ]; do
        sleep 1
        ((I++))
        echo -ne "  ${I}s\r"

        if [[ $I -ge 30 ]]; then
                break
        fi
done







#### WE MADE IT ############

echo -ne "\n"