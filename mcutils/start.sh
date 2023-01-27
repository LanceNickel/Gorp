#!/usr/bin/env bash

# THIS IS THE STARTUP SCRIPT!
# This is a utility function (ends in .sh), it should not be called directly by the command line user.
# This should not need to be updated outside of updates to functionality of the program itself.

# PARAMS:
# 1: Server directory name -- Required!



if [[ "$EUID" != 0 ]]; then
    echo "(worker) STARTUP: Insufficient privilege. Startup failed."
    exit
fi



SERVER=$1
PORT=$(cat /minecraft/servers/$SERVER/server.properties | grep server-port | cut -d "=" -f 2)



# check if screen already running
if [[ $(screen -ls | grep "$SERVER")  != "" ]]; then
    echo "(worker) STARTUP: Screen '$SERVER' already exists. Startup failed."
    exit
fi



# start a new screen with server name, run run.sh within that server's directory to start it up
echo "(worker) STARTUP: Starting server in a screen named '$SERVER'..."
sudo screen -d -m -S "$SERVER" /minecraft/servers/$SERVER/run.sh

PORT_ALIVE=false

while [ $PORT_ALIVE = false ]
do
        ((I++))

        if [[ $(sudo lsof -i:$PORT) != "" ]]; then
                echo "(worker) STARTUP: Port $PORT is alive."
                PORT_ALIVE=true
        fi

        sleep 1
done



echo "(worker) STARTUP: Startup complete. Use 'screen -r $SERVER' to get to this server's console."