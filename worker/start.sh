#!/usr/bin/env bash

### [STARTUP WORKER] ##############################################
#   Description:  Worker script that performs the startup tasks.
#   Parameters:   1: (required) Server directory name

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################



# PERMISSIONS GUARD

if [[ "$EUID" != 0 ]]; then
    echo "start.sh: Insufficient privilege. Exiting."
    exit
fi



# SCRIPT VARIABLES

SERVER=$1
PORT=$(cat /minecraft/servers/$SERVER/server.properties | grep server-port | cut -d "=" -f 2)



####



# SCREEN ALREADY EXISTS GUARD

if [[ $(screen -ls | grep "$SERVER")  != "" ]]; then
    echo "start.sh: Server '$SERVER' is already running. Exiting."
    exit
fi



# CREATE NEW SCREEN, EXECUTE SERVER'S RUN SCRIPT INSIDE

echo "start.sh: Starting server in a screen named '$SERVER'..."
sudo screen -d -m -S "$SERVER" /minecraft/servers/$SERVER/run.sh



# WAIT FOR PORT TO COME ALIVE

PORT_ALIVE=false

while [ $PORT_ALIVE = false ]
do
        ((I++))

        if [[ $(sudo lsof -i:$PORT) != "" ]]; then
                echo "start.sh: Port $PORT is alive."
                PORT_ALIVE=true
        fi

        sleep 1
done



echo "start.sh: Startup complete. Use 'screen -r $SERVER' to get to this server's console."