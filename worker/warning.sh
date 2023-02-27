#!/usr/bin/env bash

### [IN-GAME WARNING WORKER] #######################################
#   Description:  Worker script that warns players via server chat.
#   Parameters:   1: (required) Server directory name
#                 2: (required) <stop, restart, power>

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################



#### GUARDS ################

### KEY GUARD

if [[ "$1" != "pleasedontdothis" ]]; then
    echo "warning.sh: Not intended to be run directly. Exit (13)."
    exit 13
fi



#### SCRIPT PARAMETERS ################

SERVER=$2
ACTION=$3



####



# SEND WARNING MESSAGE

echo "warning.sh: Sending $ACTION warning in the chat and waiting 30 seconds..."

if [[ $ACTION == "power" ]]; then
        screen -S $SERVER -X stuff "say ATTENTION: Due to a power outage, this server must be shut down.\n"
        sleep 0.25
        screen -S $SERVER -X stuff "say ATTENTION: This server will shut down in 30 seconds.\n"
else
        screen -S $SERVER -X stuff "say ATTENTION: This server will $ACTION in 30 seconds.\n"
fi



# WAIT 30 SECONDS

NOT30=true
I=0

while [ $NOT30 == true ]; do
        sleep 1
        ((I++))
        echo -e "  ${I}s\r"

        if [[ $I == "30" ]]; then
                NOT30=false
        fi
done



echo -e "\n"