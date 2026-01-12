#!/usr/bin/env bash

### [STUFF WORKER] ################################################
#   Description:  Worker script that performs the stuff tasks.
#   Parameters:   1: (required) Server or --all for all servers
#                 2: (required) Message to send. Must be quoted, ""

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################

# Copyright (C) Lance Nickel 2026.
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

SERVER="$2"
MESSAGE="$3"







####







#### IF NOT ALL, SEND MESSAGE ############

if [[ "$SERVER" != "--all" ]]; then

    tell "$SERVER" "$MESSAGE" || handle_error "Failed to send message to server."

fi







#### IF SENDING TO ALL ############

if [[ "$SERVER" == "--all" ]]; then

    #### Loop through server directories

    for d in "$HOMEDIR"/servers/*; do

        THIS_SERVER="$(basename $d)"



        #### Only if the server is running...

        if [[ "$(is_server_running $THIS_SERVER)" == "true" ]]; then
            tell "$THIS_SERVER" "$MESSAGE" || handle_error "Failed to send message to $THIS_SERVER."
        fi

    done

fi







#### WE MADE IT ############

echo "Message sent!"
