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
    OUTPUT=true
    ERRORS=true

elif [[ "$1" == "pleaseshutup" ]]; then
    OUTPUT=false
    ERRORS=true

elif [[ "$1" == "pleasebesilent" ]]; then
    OUTPUT=false
    ERRORS=false

else
    if $ERRORS; then echo "createserver.sh: Not intended to be run directly. Exit (13)."; fi
    exit 13
fi







#### SCRIPT PARAMETERS ################

source /usr/local/bin/gorpmc/worker/i_getconfigparams.sh

SERVER=$2
WORLD=$3







####






### CREATE SERVER DIRECTORY AND COPY RUN.SH

mkdir $HOMEDIR/servers/$SERVER
cp /usr/local/bin/gorpmc/worker/run.sh $HOMEDIR/servers/$SERVER/







### PREPARE KEY FILES
#   It is not possible to get to this part of code execution without first agreeing to the Minecraft EULA via a prompt.
#   Users who did not expressly agree to the EULA did not get here, as they would not have been able to execute this script with the key (reasonably).

echo "eula=true" > $HOMEDIR/servers/$SERVER/eula.txt
touch $HOMEDIR/servers/$SERVER/server.properties



echo "level-name=world-$WORLD" > $HOMEDIR/servers/$SERVER/server.properties



if $OUTPUT; then echo "Server created!"; fi