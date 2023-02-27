#!/usr/bin/env bash

### [RESET-WORLD WORKER] ##########################################
#   Description:  Worker script that performs the world reset.
#   Parameters:   1: (required) Server directory name
#                 2: (optional) World (level) name for directory

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################



# PERMISSIONS GUARD

if [[ "$EUID" != 0 ]]; then
        echo "resetworld.sh: Insufficient privilege. Exiting."
        exit
fi



# SCRIPT VARIABLES

SERVER=$1
WORLD_TO_RESET=$(cat $HOMEDIR/servers/$SERVER/server.properties | grep 'level-name=' | cut -d '=' -f2)

if [[ $(screen -ls | grep "$SERVER")  != "" ]]; then
    RUNNING=true
else
    RUNNING=false
fi



####



# USER CONFIRMATION GUARDS

echo "You are about to reset the world named '$WORLD_TO_RESET' in the '$SERVER' server instance."

read -r -p "Did you back up the world/don't care about it? [y/n] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "resetworld.sh: Resetting world..."
else
    echo "PLEASE BACK UP YOUR WORLD FILES! Run 'mcbackup $SERVER' to take a back up first."
    exit
fi



# STOP SERVER (if already running)

if [ $RUNNING = true ]; then
    echo ("resetworld.sh: Stopping server...")
    /usr/local/bin/action/mcstop $SERVER now > /dev/null
fi



# DELETE THE WORLD

echo "resetworld.sh: Regenerating $WORLD_TO_RESET... (~45 secs)"

rm -rf $HOMEDIR/servers/$SERVER/world-$WORLD_TO_RESET
rm -rf $HOMEDIR/servers/$SERVER/world-${WORLD_TO_RESET}_nether
rm -rf $HOMEDIR/servers/$SERVER/world-${WORLD_TO_RESET}_the_end



# START SERVER (to generate world)

/usr/local/bin/action/mcstart $SERVER > /dev/null



echo "resetworld.sh: World reset. Server is running."