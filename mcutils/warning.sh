#!/usr/bin/env bash

### [IN-GAME WARNING WORKER] #######################################
#   Description:  Worker script that warns players via server chat.
#   Parameters:   1: (required) Server directory name
#                 2: (required) <stop, restart, power>

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##  This script is OVERWRITTEN any time a C.U.M. update is run.  ##
###################################################################



# PERMISSIONS GUARD

if [[ "$EUID" != 0 ]]; then
        echo "(worker) WARNING: Insufficient privilege. Warning failed."
        exit
fi



# SCRIPT VARIBLES

SERVER=$1
ACTION=$2



####



# SEND WARNING MESSAGE

echo "(worker) WARNING: Sending $ACTION warning in the chat and waiting 30 seconds..."

if [ $ACTION == "power" ]; then
        screen -S $SERVER -X stuff "say ATTENTION: Due to a power outage, this server must be shut down.\n"
        screen -S $SERVER -X stuff "say ATTENTION: This server will shut down in 30 seconds.\n"
else
        screen -S $SERVER -X stuff "say ATTENTION: This server will $ACTION in 30 seconds.\n"
fi



# WAIT 30 SECONDS

NOT30=true
I=0

while [ $NOT30 == true ];
do
        sleep 1
        ((I++))
        echo -ne "  $I s\r"

        if [ $I -eq "30" ]; then
                NOT30=false
        fi
done



echo -ne "\n"