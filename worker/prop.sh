#!/usr/bin/env bash

### [PROP WORKER] #################################################
#   Description:  Worker script that performs the world reset.
#   Parameters:   1: (required) Server directory name
#                 2: (optional) World (level) name for directory

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################

# Copyright (C) Lance Nickel 2025.
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
KEY="$3"
VALUE="$4"







####







#### UPDATE SERVER PROPERTIES ############

current="$(grep -e "^$KEY=" $HOMEDIR/servers/$SERVER/server.properties | cut -d '=' -f2)"
sed -i "s/$KEY=$current/$KEY=$VALUE/g" $HOMEDIR/servers/$SERVER/server.properties || handle_error "Failed to update server.properties."







#### WE MADE IT ############

echo "Server properties updated! Old value was: '$current'"