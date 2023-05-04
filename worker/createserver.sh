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

SERVER=$2
WORLD=$3







####






#### CREATE SERVER DIRECTORY AND COPY RUN.SH ############

mkdir $HOMEDIR/servers/$SERVER || handle_error "Failed to create server directory."
cp /usr/local/bin/gorpmc/run.sh $HOMEDIR/servers/$SERVER/ || handle_error "Failed to copy run.sh file to new server directory."







#### PREPARE SERVER FILES ############

echo "eula=true" > $HOMEDIR/servers/$SERVER/eula.txt || handle_error "Failed to echo eula accept to eula.txt."
echo "level-name=world-$WORLD" > $HOMEDIR/servers/$SERVER/server.properties || handle_error "Failed to echo to server.properties."







#### WE MADE IT ############

echo "Server created!"