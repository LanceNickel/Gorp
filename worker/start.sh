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

source /usr/local/bin/gorpmc/worker/i_getconfigparams.sh

SERVER=$2
INITIAL_BACKUP=false







####







# SCREEN ALREADY EXISTS GUARD

if [[ $(screen -ls | grep "$SERVER")  != "" ]]; then
    echo "start.sh: Server already running. Exit (33)."
    exit 33
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

echo "Starting with $WORLD..." 

screen -d -m -S "$SERVER" $HOMEDIR/servers/$SERVER/run.sh pleasedontdothis







# GIVE THE SERVER 5 SECONDS, THEN WAIT FOR SERVER TO LOG "DONE!"

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
        echo "start.sh: Startup failure. Server never indicated "done!". Exit (38)."
        exit 38
    fi

done







# IF FIRST TIME, WAIT A FEW SECONDS THEN TAKE AN INITIAL BACKUP (and also override the default end text)

if [[ $INITIAL_BACKUP == true ]]; then

    echo "Taking initial backup of world..."

    sleep 5

    /usr/local/bin/gorpmc/action/mcbackupworld pleasedontdothis $SERVER > /dev/null

    echo "The server instance first-time setup is complete. You may now join your new server instance. Happy exploring!"
else

    echo "Server started! Use 'screen -r $SERVER' to get to this server's console."
fi