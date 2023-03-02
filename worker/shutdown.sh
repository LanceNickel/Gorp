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

echo "Stopping server..."
screen -S $SERVER -X stuff 'stop\n'



# WAIT FOR SCREEN TO TERMINATE

I=0
FORCE_QUIT=false
FROZEN=false

while [ true ]; do
        sleep 1
        ((I++))

        if [[ $(screen -ls | grep "$SERVER") != "" ]]; then
                screen -S "$SERVER" -X stuff '\n'
        else
                break
        fi

        if [[ $I -eq "30" ]]; then
                FORCE_QUIT=true
                screen -X -S mc quit
        fi

        if [[ $I -eq "33" ]]; then
                FORCE_QUIT=false
                FROZEN=true
                break
        fi
done



if [[ $FORCE_QUIT == true ]]; then
        echo "shutdown.sh: The server encountered an error during shut down and was force quit. Exit (36)."
        exit 36

elif [[ $FROZEN == true ]]; then
        echo "shutdown.sh: The server encountered an error during shut down and is now in an unknown state. Exit (37)."
        exit 37

else
        echo "Server stopped!"
        
fi