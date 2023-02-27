#!/usr/bin/env bash

### [STARTUP WORKER] ##############################################
#   Description:  Worker script that performs the startup tasks.
#   Parameters:   1: (required) Server directory name

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################



#### GUARDS ################

### KEY GUARD

if [[ "$1" != "pleasedontdothis" ]]; then
    echo "start.sh: Not intended to be run directly. Exit (13)."
    exit 13
fi



#### SCRIPT PARAMETERS ################

SERVER=$2
INITIAL_BACKUP=false

# Server port

if [[ $(cat $HOMEDIR/servers/$SERVER/server.properties | grep 'server-port=') = "" ]]; then
    PORT=25565
else
    PORT=$(cat $HOMEDIR/servers/$SERVER/server.properties | grep 'server-port=' | cut -d '=' -f2)
fi



####



# SCREEN ALREADY EXISTS GUARD

if [[ $(screen -ls | grep "$SERVER")  != "" ]]; then
    echo "start.sh: Server '$SERVER' is already running. Exiting."
    exit
fi



# DETECT IF THE FIRST TIME SETUP IS NEEDED

if [[ $(cat $HOMEDIR/servers/$SERVER/server.properties | grep 'level-name=' | cut -d '=' -f2) = "" ]]; then
    INITIAL_BACKUP=true
    echo "level-name=world-default" >> $HOMEDIR/sesrvers/$SERVER/server.properties
fi



# DETECT IF INITIAL BACKUP IS NEEDED

if [[ $(cat $HOMEDIR/servers/$SERVER/server.properties | wc -l) = "1" ]]; then
    INITIAL_BACKUP=true
fi



# CREATE NEW SCREEN, EXECUTE SERVER'S RUN SCRIPT INSIDE

WORLD=$(cat $HOMEDIR/servers/$SERVER/server.properties | grep 'level-name=' | cut -d '=' -f2)

echo "start.sh: Starting instance of server '$SERVER', running world '$WORLD'..." 

screen -d -m -S "$SERVER" $HOMEDIR/servers/$SERVER/run.sh bjcisBOOMIN



# WAIT FOR PORT TO COME ALIVE

PORT_ALIVE=false

while [ $PORT_ALIVE = false ]; do
        ((I++))

        if [[ $(lsof -i:$PORT) != "" ]]; then
                echo "start.sh: Port $PORT is alive."
                PORT_ALIVE=true
        fi

        sleep 1
done



# IF FIRST TIME, WAIT A FEW SECONDS THEN TAKE AN INITIAL BACKUP (and also override the default end text)

if [[ $INITIAL_BACKUP == true ]]; then

    echo "start.sh: Taking initial backup of world... (This will take ~30 seconds longer than a normal backup, don't worry!)"

    sleep 30

    /usr/local/bin/gorpmc/action/mcbackupworld $SERVER > /dev/null

    echo "start.sh: The server instance first-time setup is complete. You may now join your new server instance. Happy exploring!"
else

    echo "start.sh: Startup complete. Use 'screen -r $SERVER' to get to this server's console."
fi