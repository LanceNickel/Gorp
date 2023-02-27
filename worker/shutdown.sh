#!/usr/bin/env bash

### [SHUTDOWN WORKER] #############################################
#   Description:  Worker script that performs the shutdown tasks.
#   Parameters:   1: (required) Server directory name

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################



#### GUARDS ################

### KEY GUARD

if [[ "$1" != "pleasedontdothis" ]]; then
    echo "shutdown.sh: Not intended to be run directly. Exit (13)."
    exit 13
fi



#### SCRIPT PARAMETERS ################

SERVER=$2



####



# STOP SERVER

echo "shutdown.sh: Stopping server..."
screen -S $SERVER -X stuff 'stop\n'



# WAIT FOR SCREEN TO TERMINATE

I=0
SCREEN=true
FORCE_QUIT=false
FROZEN=false

while [ $SCREEN = true ]; do
        ((I++))

        if [[ $(screen -ls | grep "$SERVER") != "" ]]; then
                screen -S "$SERVER" -X stuff '\n'
        else
                SCREEN=false
        fi

        if [[ $I -eq "12" ]]; then
                FORCE_QUIT=true
                screen -X -S mc quit
        fi

        if [[ $I -eq "14" ]]; then
                FORCE_QUIT=false
                FROZEN=true
        fi

        sleep 3
done



if [[ $FORCE_QUIT == true ]]; then
        echo "shutdown.sh: The server encountered an error during shut down and was force quit. Exit (36)."
        exit 36

elif [[ $FROZEN == true ]]; then
        echo "shutdown.sh: The server encountered an error during shut down and is now in an unknown state. Exit (37)."
        exit 37

else
        echo "shutdown.sh: Shutdown complete."

fi