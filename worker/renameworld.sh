#!/usr/bin/env bash

### [RESET-WORLD WORKER] ##########################################
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

SERVER=$2
CURRENT_NAME=$3
NEW_NAME=$4







####







### RENAME WORLD

mv $HOMEDIR/servers/$SERVER/world-$CURRENT_NAME/ $HOMEDIR/servers/$SERVER/world-$NEW_NAME/ || handle_error "Failed to rename overworld directory."
mv $HOMEDIR/servers/$SERVER/world-${CURRENT_NAME}_nether/ $HOMEDIR/servers/$SERVER/world-${NEW_NAME}_nether/ || handle_error "Failed to rename nether directory."
mv $HOMEDIR/servers/$SERVER/world-${CURRENT_NAME}_the_end/ $HOMEDIR/servers/$SERVER/world-${NEW_NAME}_the_end/ || handle_error "Failed to rename nether directory."







#### HANDLE SERVER.PROPERTIES ############

#### Update properties if the active world's name was the one that was changed.

ACTIVE_WORLD="$(get_active_world $SERVER)"

if [[ "$ACTIVE_WORLD" == "$CURRENT_NAME" ]]; then
    sed -i "s/level-name=world-$CURRENT_NAME/level-name=world-$NEW_NAME/g" $HOMEDIR/servers/$SERVER/server.properties || handle_error "Failed to update server.properties with new world name. You must make the change yourself."
fi








#### WE MADE IT ############

echo "World renamed!"