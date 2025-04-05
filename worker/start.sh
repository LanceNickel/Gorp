#!/usr/bin/env bash

### [STARTUP WORKER] ##############################################
#   Description:  Worker script that performs the startup tasks.
#   Parameters:   1: (required) Server directory name

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################

# Copyright (C) Lance Nickel 2025.
# Distributed under GNU GPL v3.
# <https://gorp.lanickel.com/license/>



#### SETUP ############

#### Globals

. /usr/local/bin/gorpmc/functions/exit.sh
. /usr/local/bin/gorpmc/functions/params.sh
. /usr/local/bin/gorpmc/functions/functions.sh



#### Key guard

if [[ "$1" != "pleasedontdothis" ]]; then
    handle_error "Script not meant to be run directly."
fi



#### Collect arguments & additional variables

SERVER=$2
GENERATE=$3

ACTIVE_WORLD=$(get_active_world "$SERVER")
WORLD_EXISTS=$(does_world_exist "$SERVER" "$ACTIVE_WORLD")







####







#### FIRST TIME RUNNING SERVER (bypass generate override) ############

if [[ $(cat $HOMEDIR/servers/$SERVER/server.properties | grep 'level-name=' | cut -d '=' -f2) = "" ]]; then
    echo "level-name=world-default" >> $HOMEDIR/servers/$SERVER/server.properties || handle_error "Failed to update level-name in server.properties."
    GENERATE="-y"
fi



if [[ $(cat $HOMEDIR/servers/$SERVER/server.properties | wc -l) -le 2 ]]; then
    GENERATE="-y"
fi







#### PROMPT USER TO RE-GENERATE (if this isn't first time running) ############

if [[ "$WORLD_EXISTS" == "false" ]] && [[ "$GENERATE" != "-y" ]]; then
    read -r -p "Active world ($ACTIVE_WORLD) doesn't exist. Generate new world? [y/N] " response

    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        sleep 0.005
    else
        handle_error "start.sh: User cancelled."
    fi
fi







#### START THE SERVER IN A NEW SCREEN ############

cd $HOMEDIR/servers/$SERVER/ || handle_error "Failed to cd to server directory."
echo "Starting server..."
screen -d -m -S "$SERVER" $HOMEDIR/servers/$SERVER/run.sh $1 || handle_error "Failed to start screen for world."







#### WAIT FOR LOG ############

sleep 5

I=0

while [ true ]; do
    sleep 1
    ((I++))

    if [[ "$(grep 'INFO]: Done (' $HOMEDIR/servers/$SERVER/logs/latest.log)" != "" ]]; then
        break
    fi

    if [[ $I -ge 30 ]]; then
        echo -e "\n$(tail -n15 $HOMEDIR/servers/$SERVER/logs/latest.log)\n"

        echo "Timeout reached. Above is the last 15 lines of latest.log."
        handle_error "start.sh: Startup failure. Server never indicated 'done'. Server is in an unknown state."
    fi

done







#### UPDATE VERSION INFORMATION ############

LOG_INDICATES_VERSION="$(grep 'Starting minecraft server version' $HOMEDIR/servers/$SERVER/logs/latest.log | cut -d ':' -f4 | cut -d ' ' -f6)"
echo "$LOG_INDICATES_VERSION" > $HOMEDIR/servers/$SERVER/lastrunversion







#### WE MADE IT ############

echo "Server started! Use 'screen -r $SERVER' to get to this server's console."