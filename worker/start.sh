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

if [[ "$1" == "pleasedontdothis" ]]; then
    OUTPUT=true
    ERRORS=true

elif [[ "$1" == "pleaseshutup" ]]; then
    OUTPUT=false
    ERRORS=true

elif [[ "$1" == "pleasebesilent" ]]; then
    OUTPUT=false
    ERRORS=false

else
    if $ERRORS; then echo "start.sh: Not intended to be run directly. Exit (13)."; fi
    exit 13
fi







#### SCRIPT PARAMETERS ################

source /usr/local/bin/gorpmc/worker/i_getconfigparams.sh

SERVER=$2
INITIAL_BACKUP=false







####







### DETECT IF THE FIRST TIME SETUP IS NEEDED

if [[ $(cat $HOMEDIR/servers/$SERVER/server.properties | grep 'level-name=' | cut -d '=' -f2) = "" ]]; then
    INITIAL_BACKUP=true
    echo "level-name=world-default" >> $HOMEDIR/sesrvers/$SERVER/server.properties
fi







### DETECT IF INITIAL BACKUP IS NEEDED

if [[ $(cat $HOMEDIR/servers/$SERVER/server.properties | wc -l) = "1" ]]; then
    INITIAL_BACKUP=true
fi







### CREATE NEW SCREEN, EXECUTE SERVER'S RUN SCRIPT INSIDE

WORLD=$(cat $HOMEDIR/servers/$SERVER/server.properties | grep 'level-name=' | cut -d '=' -f2)

if $OUTPUT; then echo "Starting with $WORLD..."; fi

screen -d -m -S "$SERVER" $HOMEDIR/servers/$SERVER/run.sh $1







### WAIT FOR LOG

sleep 5

I=0

while [ true ]; do
    sleep 1
    ((I++))

    if [[ "$(grep 'INFO]: Done (' $HOMEDIR/servers/$SERVER/logs/latest.log)" != "" ]]; then
        break
    fi

    if [[ $I -ge 30 ]]; then
        if $OUTPUT; then echo -e "\n$(tail -n15 $HOMEDIR/servers/$SERVER/logs/latest.log)\n"; fi

        if $OUTPUT; then echo "Timeout reached. Above is the last 15 lines of latest.log."; fi
        if $ERRORS; then echo "start.sh: Startup failure. Server never indicated 'done'. Server is in an unknown state. Exit (36)."; fi
        exit 36
    fi

done







# IF FIRST TIME, WAIT A FEW SECONDS THEN TAKE AN INITIAL BACKUP (and also override the default end text)

if [[ $INITIAL_BACKUP == true ]]; then

    if $OUTPUT; then echo "Taking initial backup of world..."; fi

    sleep 5

    /usr/local/bin/gorpmc/action/mcbackupworld pleasedontdothis $SERVER > /dev/null

    if $OUTPUT; then echo "The server instance first-time setup is complete. You may now join your new server instance. Happy exploring!"; fi
else

    if $OUTPUT; then echo "Server started! Use 'screen -r $SERVER' to get to this server's console."; fi
fi