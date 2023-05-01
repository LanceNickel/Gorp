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



#### GUARDS ################

### KEY GUARD

if [[ "$1" == "pleasedontdothis" ]]; then
    handle_error "Script not meant to be run directly."
fi







#### SCRIPT PARAMETERS ################

SERVER=$2
ACTION=$3







####







### SEND WARNING MESSAGE

echo "Giving a very polite heads up :) ..."

if [[ "$ACTION" == "power" ]]; then
        screen -S $SERVER -X stuff "say ATTENTION: Due to a power outage, this server must be shut down.\n"
        sleep 0.25
        screen -S $SERVER -X stuff "say ATTENTION: This server will shut down in 30 seconds.\n"
else
        screen -S $SERVER -X stuff "say ATTENTION: This server will $ACTION in 30 seconds.\n"
fi







### WAIT 30 SECONDS

I=0

while [ true ]; do
        sleep 1
        ((I++))
        echo -ne "  ${I}s\r"

        if [[ $I -ge 30 ]]; then
                break
        fi
done







echo -ne "\n"