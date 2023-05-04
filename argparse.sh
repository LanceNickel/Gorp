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







####







### PARAMS RT-GUARD

if [[ "$GAMEVER" == "" ]] || [[ "$RAM" == "" ]] || [[ "$HOMEDIR" == "" ]] || [[ "$BACKUP_DEST" == "" ]] || [[ "$ARCHIVE_DEST" == "" ]] || [[ "$LATEST_JAR" == "" ]]; then
    echo "One or more required options in gorp.conf not set."
fi







### ACTIONS

if [[ "$ACTION" == "backup-world" ]]; then
    source /usr/local/bin/gorpmc/action/mcbackupworld $TESTSTRING $ARG1 || handle_error "Failed to run action."

elif [[ "$ACTION" == "backup-server" ]]; then
    source /usr/local/bin/gorpmc/action/mcbackupserver $TESTSTRING $ARG1 || handle_error "Failed to run action."

elif [[ "$ACTION" == "restore-world" ]]; then
    source /usr/local/bin/gorpmc/action/mcrestoreworld $TESTSTRING $ARG1 || handle_error "Failed to run action."

elif [[ "$ACTION" == "restore-server" ]]; then
    source /usr/local/bin/gorpmc/action/mcrestoreserver $TESTSTRING $ARG1 || handle_error "Failed to run action."

elif [[ "$ACTION" == "update-jar" ]]; then
    source /usr/local/bin/gorpmc/action/mcupdatejar $TESTSTRING || handle_error "Failed to run action."

elif [[ "$ACTION" == "get-jar" ]]; then
    source /usr/local/bin/gorpmc/action/mcgetjar $TESTSTRING $ARG1 $ARG2 || handle_error "Failed to run action."

elif [[ "$ACTION" == "create-server" ]]; then
    source /usr/local/bin/gorpmc/action/mccreateserver $TESTSTRING $ARG1 $ARG2 || handle_error "Failed to run action."

elif [[ "$ACTION" == "delete-server" ]]; then
    source /usr/local/bin/gorpmc/action/mcdeleteserver $TESTSTRING $ARG1 || handle_error "Failed to run action."

elif [[ "$ACTION" == "create-world" ]]; then
    source /usr/local/bin/gorpmc/action/mccreateworld $TESTSTRING $ARG1 $ARG2 || handle_error "Failed to run action."

elif [[ "$ACTION" == "delete-world" ]]; then
    source /usr/local/bin/gorpmc/action/mcdeleteworld $TESTSTRING $ARG1 $ARG2 || handle_error "Failed to run action."

elif [[ "$ACTION" == "reset-world" ]]; then
    source /usr/local/bin/gorpmc/action/mcresetworld $TESTSTRING $ARG1 || handle_error "Failed to run action."

elif [[ "$ACTION" == "archive-world" ]]; then
    source /usr/local/bin/gorpmc/action/mcarchiveworld $TESTSTRING $ARG1 $ARG2 || handle_error "Failed to run action."

elif [[ "$ACTION" == "switch-world" ]]; then
    source /usr/local/bin/gorpmc/action/mcswitchworld $TESTSTRING $ARG1 $ARG2 || handle_error "Failed to run action."

elif [[ "$ACTION" == "power" ]]; then
    source /usr/local/bin/gorpmc/action/mcpower $TESTSTRING || handle_error "Failed to run action."

elif [[ "$ACTION" == "start" ]]; then
    source /usr/local/bin/gorpmc/action/mcstart $TESTSTRING $ARG1 $ARG2 || handle_error "Failed to run action."

elif [[ "$ACTION" == "stop" ]]; then
    source /usr/local/bin/gorpmc/action/mcstop $TESTSTRING $ARG1 $ARG2 || handle_error "Failed to run action."

elif [[ "$ACTION" == "restart" ]]; then
    source /usr/local/bin/gorpmc/action/mcrestart $TESTSTRING $ARG1 $ARG2 || handle_error "Failed to run action."

elif [[ "$ACTION" == "help" ]]; then
    source /usr/local/bin/gorpmc/action/gorphelp || handle_error "Failed to run action."

elif [[ "$ACTION" == "upgrade" ]]; then
    source /usr/local/bin/gorpmc/action/gorpupgrade $TESTSTRING || handle_error "Failed to run action."

elif [[ "$ACTION" == "-v" ]]; then
    source /usr/local/bin/gorpmc/action/gorpversion || handle_error "Failed to run action."

elif [[ "$ACTION" == "-s" ]]; then
    source /usr/local/bin/gorpmc/action/mcserverstatus $TESTSTRING $ARG1 || handle_error "Failed to run action."

elif [[ "$ACTION" == "tail" ]]; then
    tail -f $HOMEDIR/servers/$ARG1/logs/latest.log || handle_error "Failed to tail latest.log"

elif [[ "$ACTION" == "ls" ]]; then
    echo $(ls $HOMEDIR/servers)

elif [[ "$ACTION" == "move-home" ]]; then
    source /usr/local/bin/gorpmc/action/gorpmovehome $TESTSTRING $ARG1 || handle_error "Failed to run action."

else
    echo "Invalid parameters. Use gorp help for more information."
fi