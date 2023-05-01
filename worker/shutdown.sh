#!/usr/bin/env bash

### [SHUTDOWN WORKER] #############################################
#   Description:  Worker script that performs the shutdown tasks.
#   Parameters:   1: (required) Server directory name

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################

# Copyright (C) Lance Nickel 2023.
# Distributed under GNU GPL v3.
# <https://gorp.lanickel.com/license/>



#### GUARDS ################

### KEY GUARD

if [[ "$1" == "pleasedontdothis" ]]; then
    handle_error "Script not meant to be run directly."
fi







#### SCRIPT PARAMETERS ################

SERVER=$2







####







### STOP SERVER

if [[ "$VERBOSE" == "v" ]]; then
    if $OUTPUT; then echo "Stopping server in verbose mode... (Press CTRL+C in case server hangs)."; fi
else
    if $OUTPUT; then echo "Stopping server..."; fi
fi



screen -S $SERVER -X stuff 'stop\n'







### WAIT FOR LOG

sleep 1

I=0
while true; do
    sleep 1
    ((I++))

    if [[ "$(grep 'INFO]: Closing Server' $HOMEDIR/servers/$SERVER/logs/latest.log)" != "" ]]; then
        
        J=0
        while [[ $J -le 5 ]]; do
            sleep 1
            ((J++))
            screen -S $SERVER -X stuff '\n' > /dev/null
        done

        break
    fi

    if [[ $I -ge 30 ]]; then
        if $OUTPUT; then echo -e "\n$(tail -n15 $HOMEDIR/servers/$SERVER/logs/latest.log)\n"; fi

        if $OUTPUT; then echo "Timeout reached. Above is the last 15 lines of latest.log."; fi
        if $ERRORS; then echo "shutdown.sh: Shutdown failure. Server never indicated 'stopping'. Server is in an unknown state. Exit (37)."; fi
        exit 37
    fi
done







sleep 1

if $OUTPUT; then echo "Server stopped!"; fi