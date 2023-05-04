#!/usr/bin/env bash

### [SERVERSTATUS] ################################################
#   Description:  Action script to setup backup restore worker.
#   Parameters:   1: (required) Server directory name

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################

# Copyright (C) Lance Nickel 2023.
# Distributed under GNU GPL v3.
# <https://gorp.lanickel.com/license/>



#### SETUP ############

#### Key guard

if [[ "$1" == "pleasedontdothis" ]]; then
    handle_error "Script not meant to be run directly."
fi



#### Globals

source /usr/local/bin/gorpmc/functions/exit.sh
source /usr/local/bin/gorpmc/functions/params.sh
source /usr/local/bin/gorpmc/functions/functions.sh



#### Collect arguments & additional variables

SERVER=$2







####







#### GUARDS ############

#### Bad user input

if [[ "$SERVER" == "" ]]; then
    handle_error "Bad input. Expected: gorp -s [server-name]"
fi






#### GET THE RELEVANT DATA ############

#### Status array

# status.running
if [[ $(screen -ls | grep "$SERVER") != "" ]]; then
    STATUS_RUNNING="true"
else
    STATUS_RUNNING="false"
fi


# status.version
STATUS_VERSION="$(cat $HOMEDIR/servers/$SERVER/lastrunversion)"

if [[ "$STATUS_VERSION" == "" ]]; then
    STATUS_VERSION="none"
fi


# status.jar_file
STATUS_JAR="$(cat $HOMEDIR/servers/$SERVER/run.sh | grep "^[^#;]" | grep 'JAR=' | cut -d '=' -f2)"

if [[ "$STATUS_JAR" == '$LATEST_JAR' ]]; then
    STATUS_JAR=$LATEST_JAR
fi


# status.ram
STATUS_RAM="$(cat $HOMEDIR/servers/$SERVER/run.sh | grep "^[^#;]" | grep 'RAM=' | cut -d '=' -f2)"

if [[ "$STATUS_RAM" == '$RAM' ]]; then
    STATUS_RAM=$RAM
fi


# status.path
STATUS_PATH=$HOMEDIR/servers/$SERVER







#### World array

# world.active
WORLD_ACTIVE="$(grep 'level-name' $HOMEDIR/servers/$SERVER/server.properties | cut -d '=' -f2)"


# world sizes
WORLD_TOTAL=$(du -shc $HOMEDIR/servers/$SERVER/$WORLD_ACTIVE* 2> /dev/null | tail -n1 | cut -d$'\t' -f1)
WORLD_O="$(du -shc $HOMEDIR/servers/$SERVER/$WORLD_ACTIVE/ 2> /dev/null | tail -n1 | cut -d$'\t' -f1)"
WORLD_N="$(du -shc $HOMEDIR/servers/$SERVER/${WORLD_ACTIVE}_nether/ 2> /dev/null | tail -n1 | cut -d$'\t' -f1)"
WORLD_E="$(du -shc $HOMEDIR/servers/$SERVER/${WORLD_ACTIVE}_the_end/ 2> /dev/null | tail -n1 | cut -d$'\t' -f1)"







#### Properties array

# properties.whitelist
PROPERTIES_WHITELIST="$(grep 'enforce-whitelist=' $HOMEDIR/servers/$SERVER/server.properties | cut -d '=' -f2)"


# properties.gamemode
PROPERTIES_GAMEMODE="$(grep 'gamemode=' $HOMEDIR/servers/$SERVER/server.properties | cut -d '=' -f2)"


# properties.difficulty
PROPERTIES_DIFFICULTY="$(grep 'difficulty=' $HOMEDIR/servers/$SERVER/server.properties | cut -d '=' -f2)"


# properties.hardcore
PROPERTIES_HARDCORE="$(grep 'hardcore=' $HOMEDIR/servers/$SERVER/server.properties | cut -d '=' -f2)"


# properties.server_port
PROPERTIES_PORT="$(grep 'server-port=' $HOMEDIR/servers/$SERVER/server.properties | cut -d '=' -f2)"







#### PRINT THE JSON

cat <<EOF
{
  "status": [
    {
      "running": $STATUS_RUNNING,
      "version": "$STATUS_VERSION",
      "jar_file": "$STATUS_JAR",
      "ram": "$STATUS_RAM",
      "path": "$STATUS_PATH"
    }
  ],
  "world": [
    {
      "active": "$WORLD_ACTIVE",
      "total_size": "$WORLD_TOTAL",
      "o_size": "$WORLD_O",
      "n_size": "$WORLD_N",
      "e_size": "$WORLD_E"
    }
  ],
  "properties": [
    {
      "whitelist": $PROPERTIES_WHITELIST,
      "gamemode": "$PROPERTIES_GAMEMODE",
      "difficulty": "$PROPERTIES_DIFFICULTY",
      "hardcore": $PROPERTIES_HARDCORE,
      "server_port": $PROPERTIES_PORT
    }
  ]
}
EOF