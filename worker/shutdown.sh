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
        echo "shutdown.sh: Insufficient privilege. Exiting."
        exit
fi



# SCREEN NOT RUNNING GUARD

if [[ $(screen -ls | grep "$SERVER")  = "" ]]; then
        echo "shutdown.sh: Server '$SERVER' is not running. Exiting."
fi



# SCRIPT VARIABLES

SERVER=$1



####



# STOP SERVER

echo "shutdown.sh: Stopping server..."
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
                echo "shutdown.sh: This is taking longer than expected..."
        fi

        if [ $I -eq "12" ]; then
                echo "shutdown.sh: The server shutdown process has hung. The server will be force-quit."
                sleep 0.05
                echo "Please investigate this further in the server log: '$HOMEDIR/servers/$SERVER/logs/latest.log'."
                screen -X -S mc quit
        fi

        if [ $I -eq "13" ]; then
                echo "shutdown.sh: Cannot get screen $SERVER to quit. Shutdown will now exit. Please investigate, something is in a very broken state."
                exit
        fi

        sleep 3
done



echo "shutdown.sh: Shutdown complete."