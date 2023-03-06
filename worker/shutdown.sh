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

source /usr/local/bin/gorpmc/worker/i_getconfigparams.sh

SERVER=$2
VERBOSE=$3







####







### STOP SERVER

if [[ "$VERBOSE" == "v" ]]; then
    echo "Stopping server in verbose mode... (Press CTRL+C in case server hangs)."
else
    echo "Stopping server..."
fi



screen -S $SERVER -X stuff 'stop\n'







### SHOW LOG (if set to verbose)

if [[ "$VERBOSE" == "v" ]]; then

    sleep 1

    tail -f $HOMEDIR/servers/$SERVER/logs/latest.log | sed '/^INFO]: Closing Server$/ q'

fi







### WAIT FOR LOG (if not set to verbose)

if [[ "$VERBOSE" != "v" ]]; then

    sleep 1

    I=0

    while [ true ]; do
        sleep 1
        ((I++))

        if [[ "$(grep 'INFO]: Closing Server' $HOMEDIR/servers/$SERVER/logs/latest.log)" != "" ]]; then
            break
        fi

        if [[ $I -ge 30 ]]; then
            echo -e "\n$(tail -n15 $HOMEDIR/servers/$SERVER/logs/latest.log)\n"

            echo "Timeout reached. Above is the last 15 lines of latest.log."
            echo "shutdown.sh: Shutdown failure. Server never indicated 'stopping'. Server is in an unknown state. Exit (37)."
            exit 37
        fi
    done

fi







sleep 1

echo "Server stopped!"