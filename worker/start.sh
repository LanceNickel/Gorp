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



####



# SCREEN ALREADY EXISTS GUARD

if [[ $(screen -ls | grep "$SERVER")  != "" ]]; then
    echo "start.sh: Server '$SERVER' is already running. Exiting."
    exit
fi



# DETECT IF THE FIRST TIME SETUP IS NEEDED

if [[ $(ls /minecraft/servers/$SERVER/ | grep 'server.properties') = "" ]]; then
    echo "start.sh: Performing first-run setup. This will take about 1 minute and will restart the server."

    screen -d -m -S "$SERVER" /minecraft/servers/$SERVER/run.sh
    
    sleep 30

    /bin/gorputils/action/mcstop $SERVER now > /dev/null

    sed -i "s/level-name=world/level-name=world-default/" /minecraft/servers/$SERVER/server.properties

    rm -rf /minecraft/servers/$SERVER/world
    rm -rf /minecraft/servers/$SERVER/world_nether
    rm -rf /minecraft/servers/$SERVER/world_the_end
fi



# CREATE NEW SCREEN, EXECUTE SERVER'S RUN SCRIPT INSIDE

WORLD=$(cat /minecraft/servers/$SERVER/server.properties | grep 'level-name=' | cut -d '=' -f2)

echo "start.sh: Starting instance of server '$SERVER', running world '$WORLD'..." 
screen -d -m -S "$SERVER" /minecraft/servers/$SERVER/run.sh



# WAIT FOR PORT TO COME ALIVE

PORT=$(cat /minecraft/servers/$SERVER/server.properties | grep server-port | cut -d "=" -f 2)

PORT_ALIVE=false

while [ $PORT_ALIVE = false ]
do
        ((I++))

        if [[ $(lsof -i:$PORT) != "" ]]; then
                echo "start.sh: Port $PORT is alive."
                PORT_ALIVE=true
        fi

        sleep 1
done



echo "start.sh: Startup complete. Use 'screen -r $SERVER' to get to this server's console."