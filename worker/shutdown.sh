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



#### SETUP ############

#### Globals

source /usr/local/bin/gorpmc/functions/exit.sh
source /usr/local/bin/gorpmc/functions/params.sh
source /usr/local/bin/gorpmc/functions/functions.sh



#### Key guard

if [[ "$1" != "pleasedontdothis" ]]; then
    handle_error "Script not meant to be run directly."
fi



#### Collect arguments & additional variables

SERVER=$2







####







#### STOP THE SERVER ############

echo "Stopping server..."
screen -S $SERVER -X stuff 'stop\n' || handle_error "Failed to stuff 'stop' into $SERVER"







#### WAIT FOR LOG ############

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
            screen -S $SERVER -X stuff '\n' > /dev/null || handle_error "Failed to stuff '\n' into $SERVER"
        done

        break
    fi

    if [[ $I -ge 30 ]]; then
        echo -e "\n$(tail -n15 $HOMEDIR/servers/$SERVER/logs/latest.log)\n"

        echo "Timeout reached. Above is the last 15 lines of latest.log."
        handle_error "Shutdown failure. Server never indicated 'stopping'. Server is in an unknown state."
    fi
done







#### WE MADE IT ############

echo "Server stopped!"