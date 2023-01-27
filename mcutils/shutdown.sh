#!/usr/bin/env bash

# THIS IS THE SHUT DOWN SCRIPT!
# This is a utility function (ends in .sh), it should not be called directly by the command line user.
# This should not need to be updated outside of updates to functionality of the program itself.

# PARAMS:
# 1: Server directory name -- Required!



if [[ "$EUID" != 0 ]]; then
        echo "(worker) SHUTDOWN: Insufficient privilege. Shutdown failed."
        exit
fi



# check if screen is running
if [[ $(screen -ls | grep "$SERVER")  = "" ]]; then
        echo "(worker) SHUTDOWN: Screen '$SERVER' is not running. Shutdown failed."
fi



SERVER=$1



# issue stop command to server
echo "(worker) SHUTDOWN: Stopping server..."
screen -S $SERVER -X stuff 'stop\n'



# wait for screen to terminate
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