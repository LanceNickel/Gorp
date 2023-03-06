#!/usr/bin/env bash

### [SERVERSTATUS] ################################################
#   Description:  Action script to setup backup restore worker.
#   Parameters:   1: (required) Server directory name

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################



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
    if $ERRORS; then echo "serverstatus.sh: Not intended to be run directly. Exit (13)."; fi
    exit 13
fi






#### SCRIPT PARAMETERS ################

source /usr/local/bin/gorpmc/worker/i_getconfigparams.sh

SERVER=$2







####







### PARAM RT-GUARD

if [[ "$SERVER" == "" ]]; then
    if $ERRORS; then echo "serverstatus.sh: Bad input. Expected: 'gorp -s [server-name]'. Exit (14)."; fi
    exit 14
fi






#################### GET AND STORE ALL JSON ELEMENTS AS VARIABLES







### STATUS ARRAY

# status.running
if [[ $(screen -ls | grep "$SERVER") != "" ]]; then
    STATUS_RUNNING="true"
else
    STATUS_RUNNING="false"
fi



# status.version
STATUS_VERSION="$(grep 'Starting minecraft server version' $HOMEDIR/servers/$SERVER/logs/latest.log | cut -d ':' -f4 | cut -d ' ' -f6)"

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







### WORLD ARRAY

# world.active
WORLD_ACTIVE="$(grep 'level-name' $HOMEDIR/servers/$SERVER/server.properties | cut -d '=' -f2)"



# world.total_size
WORLD_TOTAL=$(du -shc $HOMEDIR/servers/$SERVER/$WORLD_ACTIVE* | tail -n1 | cut -d$'\t' -f1)



# world.o_size
WORLD_O="$(du -sh $HOMEDIR/servers/$SERVER/$WORLD_ACTIVE/ | cut -d$'\t' -f1)"



# world.n_size
WORLD_N="$(du -sh $HOMEDIR/servers/$SERVER/${WORLD_ACTIVE}_nether/ | cut -d$'\t' -f1)"



# world.e_size
WORLD_E="$(du -sh $HOMEDIR/servers/$SERVER/${WORLD_ACTIVE}_the_end/ | cut -d$'\t' -f1)"







### PROPERTIES ARRAY

# properties.whitelist
PROPERTIES_WHITELIST="$(grep 'enforce-whitelist=' $HOMEDIR/servers/$SERVER/server.properties | cut -d '=' -f2)"



# properties.gamemode
PROPERTIES_GAMEMODE="$(grep 'force-gamemode=' $HOMEDIR/servers/$SERVER/server.properties | cut -d '=' -f2)"



# properties.difficulty
PROPERTIES_DIFFICULTY="$(grep 'difficulty=' $HOMEDIR/servers/$SERVER/server.properties | cut -d '=' -f2)"



# properties.hardcore
PROPERTIES_HARDCORE="$(grep 'hardcore=' $HOMEDIR/servers/$SERVER/server.properties | cut -d '=' -f2)"



# properties.server_port
PROPERTIES_PORT="$(grep 'server-port=' $HOMEDIR/servers/$SERVER/server.properties | cut -d '=' -f2)"







#################### RETURN STATUS IN JSON







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