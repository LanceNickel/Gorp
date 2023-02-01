#!/usr/bin/env bash

### [SHUTDOWN WORKER] #############################################
#   Description:  Worker script that performs the shutdown tasks.
#   Parameters:   1: (required) Server directory name

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################



# PERMISSIONS GUARD

if [[ "$EUID" != 0 ]]; then
        echo "(worker) SHUTDOWN: Insufficient privilege. Shutdown failed."
        exit
fi



# SCREEN NOT RUNNING GUARD

if [[ $(screen -ls | grep "$SERVER")  = "" ]]; then
        echo "(worker) SHUTDOWN: Screen '$SERVER' is not running. Shutdown failed."
fi



# SCRIPT VARIABLES

SERVER=$1



####



# STOP SERVER

echo "(worker) SHUTDOWN: Stopping server..."
screen -S $SERVER -X stuff 'stop\n'



# WAIT FOR SCREEN TO TERMINATE

I=0
SCREEN=true

while [ $SCREEN = true ];
do
        ((I++))

        if [[ $(screen -ls | grep "$SERVER") != "" ]]; then
                screen -S "$SERVER" -X stuff '\n'
        fi

        if [[ $(screen -ls | grep "$SERVER")  = "" ]]; then
                SCREEN=false
        fi

        if [ $I -eq "6" ]; then
                echo "(worker) SHUTDOWN: This is taking longer than expected..."
        fi

        if [ $I -eq "12" ]; then
                echo "(worker) SHUTDOWN: The server process has hung, force quitting. Plese check Minecraft server logs after to figure out what happened."
                screen -X -S mc quit
        fi

        if [ $I -eq "13" ]; then
                echo "(worker) SHUTDOWN: Cannot get screen $SERVER to quit. Shutdown will now exit. Please investigate, something is in a very broken state."
                exit
        fi

        sleep 3
done



echo "(worker) SHUTDOWN: Shutdown complete."