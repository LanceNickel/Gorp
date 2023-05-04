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

# Copyright (C) Lance Nickel 2023.
# Distributed under GNU GPL v3.
# <https://gorp.lanickel.com/license/>

# Yes, I am aware this file is an absoluate abomination. Counterpoint: It works.
# I'll get around to cleaning it up sometime in late-beta.



### SET DEFAULT PARAMS FOR NO FLAGS

TESTSTRING=pleasedontdothis
ACTION=$1
$ARG1=$2
$ARG2=$3







####







#### ACTIONS (i'm truly sorry for this) ############

if [[ "$ACTION" == "backup-world" ]]; then
    bash /usr/local/bin/gorpmc/action/mcbackupworld $TESTSTRING $ARG1 || handle_error "Failed to run action."

elif [[ "$ACTION" == "backup-server" ]]; then
    bash /usr/local/bin/gorpmc/action/mcbackupserver $TESTSTRING $ARG1 || handle_error "Failed to run action."

elif [[ "$ACTION" == "restore-world" ]]; then
    bash /usr/local/bin/gorpmc/action/mcrestoreworld $TESTSTRING $ARG1 || handle_error "Failed to run action."

elif [[ "$ACTION" == "restore-server" ]]; then
    bash /usr/local/bin/gorpmc/action/mcrestoreserver $TESTSTRING $ARG1 || handle_error "Failed to run action."

elif [[ "$ACTION" == "update-jar" ]]; then
    bash /usr/local/bin/gorpmc/action/mcupdatejar $TESTSTRING || handle_error "Failed to run action."

elif [[ "$ACTION" == "get-jar" ]]; then
    bash /usr/local/bin/gorpmc/action/mcgetjar $TESTSTRING $ARG1 $ARG2 || handle_error "Failed to run action."

elif [[ "$ACTION" == "create-server" ]]; then
    bash /usr/local/bin/gorpmc/action/mccreateserver $TESTSTRING $ARG1 $ARG2 || handle_error "Failed to run action."

elif [[ "$ACTION" == "delete-server" ]]; then
    bash /usr/local/bin/gorpmc/action/mcdeleteserver $TESTSTRING $ARG1 || handle_error "Failed to run action."

elif [[ "$ACTION" == "create-world" ]]; then
    bash /usr/local/bin/gorpmc/action/mccreateworld $TESTSTRING $ARG1 $ARG2 || handle_error "Failed to run action."

elif [[ "$ACTION" == "delete-world" ]]; then
    bash /usr/local/bin/gorpmc/action/mcdeleteworld $TESTSTRING $ARG1 $ARG2 || handle_error "Failed to run action."

elif [[ "$ACTION" == "reset-world" ]]; then
    bash /usr/local/bin/gorpmc/action/mcresetworld $TESTSTRING $ARG1 || handle_error "Failed to run action."

elif [[ "$ACTION" == "archive-world" ]]; then
    bash /usr/local/bin/gorpmc/action/mcarchiveworld $TESTSTRING $ARG1 $ARG2 || handle_error "Failed to run action."

elif [[ "$ACTION" == "switch-world" ]]; then
    bash /usr/local/bin/gorpmc/action/mcswitchworld $TESTSTRING $ARG1 $ARG2 || handle_error "Failed to run action."

elif [[ "$ACTION" == "power" ]]; then
    bash /usr/local/bin/gorpmc/action/mcpower $TESTSTRING || handle_error "Failed to run action."

elif [[ "$ACTION" == "start" ]]; then
    bash /usr/local/bin/gorpmc/action/mcstart $TESTSTRING $ARG1 $ARG2 || handle_error "Failed to run action."

elif [[ "$ACTION" == "stop" ]]; then
    bash /usr/local/bin/gorpmc/action/mcstop $TESTSTRING $ARG1 $ARG2 || handle_error "Failed to run action."

elif [[ "$ACTION" == "restart" ]]; then
    bash /usr/local/bin/gorpmc/action/mcrestart $TESTSTRING $ARG1 $ARG2 || handle_error "Failed to run action."

elif [[ "$ACTION" == "help" ]]; then
    bash /usr/local/bin/gorpmc/action/gorphelp || handle_error "Failed to run action."

elif [[ "$ACTION" == "upgrade" ]]; then
    bash /usr/local/bin/gorpmc/action/gorpupgrade $TESTSTRING || handle_error "Failed to run action."

elif [[ "$ACTION" == "-v" ]]; then
    bash /usr/local/bin/gorpmc/action/gorpversion || handle_error "Failed to run action."

elif [[ "$ACTION" == "-s" ]]; then
    bash /usr/local/bin/gorpmc/action/mcserverstatus $TESTSTRING $ARG1 || handle_error "Failed to run action."

elif [[ "$ACTION" == "tail" ]]; then
    tail -f $HOMEDIR/servers/$ARG1/logs/latest.log || handle_error "Failed to tail latest.log"

elif [[ "$ACTION" == "ls" ]]; then
    echo $(ls $HOMEDIR/servers)

elif [[ "$ACTION" == "move-home" ]]; then
    bash /usr/local/bin/gorpmc/action/gorpmovehome $TESTSTRING $ARG1 || handle_error "Failed to run action."

else
    echo "Invalid parameters. Use gorp help for more information."
fi