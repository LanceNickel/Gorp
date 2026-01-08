#!/usr/bin/env bash

### [ARG-INT] #####################################################
#   Description:  The argument interpreter. Called ONLY by entry.
#   Parameters:   1: (required) Action
#                 2: (optional) Argument 1
#                 3: (optional) Argument 2

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################

# Copyright (C) Lance Nickel 2025.
# Distributed under GNU GPL v3.
# <https://gorp.lanickel.com/license/>

# Yes, I am aware this file is an absoluate abomination. Counterpoint: It works.
# I'll get around to cleaning it up sometime in late-beta.



### SET DEFAULT PARAMS FOR NO FLAGS

TESTSTRING="pleasedontdothis"
ACTION="$1"
ARG1="$2"
ARG2="$3"
ARG3="$4"



### Get globals

. /usr/local/bin/gorpmc/functions/exit.sh
. /usr/local/bin/gorpmc/functions/params.sh
. /usr/local/bin/gorpmc/functions/functions.sh







####







#### ACTIONS (lord forgive me for the code below) ############

if [[ "$ACTION" == "backup-world" ]]; then
    bash /usr/local/bin/gorpmc/action/mcbackupworld "$TESTSTRING" "$ARG1"

elif [[ "$ACTION" == "backup-server" ]]; then
    bash /usr/local/bin/gorpmc/action/mcbackupserver "$TESTSTRING" "$ARG1"

elif [[ "$ACTION" == "restore-world" ]]; then
    bash /usr/local/bin/gorpmc/action/mcrestoreworld "$TESTSTRING" "$ARG1"

elif [[ "$ACTION" == "restore-server" ]]; then
    bash /usr/local/bin/gorpmc/action/mcrestoreserver "$TESTSTRING" "$ARG1"

elif [[ "$ACTION" == "update-jar" ]]; then
    bash /usr/local/bin/gorpmc/action/mcupdatejar "$TESTSTRING"

elif [[ "$ACTION" == "get-jar" ]]; then
    bash /usr/local/bin/gorpmc/action/mcgetjar "$TESTSTRING" "$ARG1" "$ARG2"

elif [[ "$ACTION" == "create-server" ]]; then
    bash /usr/local/bin/gorpmc/action/mccreateserver "$TESTSTRING" "$ARG1" "$ARG2" "$ARG3"

elif [[ "$ACTION" == "delete-server" ]]; then
    bash /usr/local/bin/gorpmc/action/mcdeleteserver "$TESTSTRING" "$ARG1"

elif [[ "$ACTION" == "prop" ]]; then
    bash /usr/local/bin/gorpmc/action/mcprop "$TESTSTRING" "$ARG1" "$ARG2" "$ARG3"

elif [[ "$ACTION" == "create-world" ]]; then
    bash /usr/local/bin/gorpmc/action/mccreateworld "$TESTSTRING" "$ARG1" "$ARG2"

elif [[ "$ACTION" == "delete-world" ]]; then
    bash /usr/local/bin/gorpmc/action/mcdeleteworld "$TESTSTRING" "$ARG1" "$ARG2"

elif [[ "$ACTION" == "rename-world" ]]; then
    bash /usr/local/bin/gorpmc/action/mcrenameworld "$TESTSTRING" "$ARG1" "$ARG2" "$ARG3"

elif [[ "$ACTION" == "reset-world" ]]; then
    bash /usr/local/bin/gorpmc/action/mcresetworld "$TESTSTRING" "$ARG1"

elif [[ "$ACTION" == "archive-world" ]]; then
    bash /usr/local/bin/gorpmc/action/mcarchiveworld "$TESTSTRING" "$ARG1" "$ARG2"

elif [[ "$ACTION" == "switch-world" ]]; then
    bash /usr/local/bin/gorpmc/action/mcswitchworld "$TESTSTRING" "$ARG1" "$ARG2"

elif [[ "$ACTION" == "power" ]]; then
    bash /usr/local/bin/gorpmc/action/mcpower "$TESTSTRING"

elif [[ "$ACTION" == "start" ]]; then
    bash /usr/local/bin/gorpmc/action/mcstart "$TESTSTRING" "$ARG1" "$ARG2"

elif [[ "$ACTION" == "stop" ]]; then
    bash /usr/local/bin/gorpmc/action/mcstop "$TESTSTRING" "$ARG1" "$ARG2"

elif [[ "$ACTION" == "restart" ]]; then
    bash /usr/local/bin/gorpmc/action/mcrestart "$TESTSTRING" "$ARG1" "$ARG2"

elif [[ "$ACTION" == "tell" ]]; then
    bash /usr/local/bin/gorpmc/action/mcstuff "$TESTSTRING" "$ARG1" "$ARG2"

elif [[ "$ACTION" == "stuff" ]]; then
    bash /usr/local/bin/gorpmc/action/mcstuff "$TESTSTRING" "$ARG1" "$ARG2"

elif [[ "$ACTION" == "help" ]]; then
    bash /usr/local/bin/gorpmc/action/gorphelp

elif [[ "$ACTION" == "config" ]]; then
    bash /usr/local/bin/gorpmc/action/gorpconfig "$TESTSTRING" "$ARG1"

elif [[ "$ACTION" == "-v" ]]; then
    bash /usr/local/bin/gorpmc/action/gorpversion

elif [[ "$ACTION" == "-s" ]]; then
    bash /usr/local/bin/gorpmc/action/mcserverstatus "$TESTSTRING" "$ARG1"

elif [[ "$ACTION" == "-f" ]]; then
    tail -f $HOMEDIR/servers/"$ARG1"/logs/latest.log || handle_error "Failed to tail latest.log"

elif [[ "$ACTION" == "ls" ]]; then
    echo "$(ls $HOMEDIR/servers)"

elif [[ "$ACTION" == "move-home" ]]; then
    bash /usr/local/bin/gorpmc/action/gorpmovehome "$TESTSTRING" "$ARG1"

else
    echo "Invalid action. Use gorp help for more information."
fi
