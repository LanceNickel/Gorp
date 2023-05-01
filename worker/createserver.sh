#!/usr/bin/env bash

### [CREATE WORKER] ###############################################
#   Description:  Worker script that performs the new server tasks.
#   Parameters:   1: (required) Server directory name
#   Parameters:   2: (required) World name

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
WORLD=$3







####






### CREATE SERVER DIRECTORY AND COPY RUN.SH

mkdir $HOMEDIR/servers/$SERVER || handle_error "Failed to mkdir $HOMEDIR/servers/$SERVER"
cp /usr/local/bin/gorpmc/worker/run.sh $HOMEDIR/servers/$SERVER/ || handle_error "Failed to copy run.sh file to new server directory"







### PREPARE KEY FILES
#   It is not possible to get to this part of code execution without first agreeing to the Minecraft EULA via a prompt.
#   Users who did not expressly agree to the EULA did not get here, as they would not have been able to execute this script with the key (reasonably).

echo "eula=true" > $HOMEDIR/servers/$SERVER/eula.txt || handle_error "Failed to echo eula accept to eula.txt"
touch $HOMEDIR/servers/$SERVER/server.properties || handle_error "Failed to touch server.properties"



echo "level-name=world-$WORLD" > $HOMEDIR/servers/$SERVER/server.properties || handle_error "Failed to echo to server.properties"



echo "Server created!"