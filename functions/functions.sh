#!/usr/bin/env bash

### [FUNCTIONS] ###################################################
#   Description: Generic functions to make code more modular.

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################

# Copyright (C) Lance Nickel 2023.
# Distributed under GNU GPL v3.
# <https://gorp.lanickel.com/license/>



######## GET PARAMS

. /usr/local/bin/gorpmc/functions/params.sh



######## WORLD-RELATED FUNCTIONS

#### List worlds (server name)

list_worlds() {
    echo $(ls $HOMEDIR/servers/$1/ | grep '_nether' | cut -d '-' -f2 | cut -d '_' -f1)
}



#### Check if world exists (server name, world name)

does_world_exist() {
    if [[ -d "$HOMEDIR/servers/$1/$2" ]]; then
        echo "true"
    else
        echo "false"
    fi
}



#### Get server's active world (server name)

get_active_world() {
    echo $(cat $HOMEDIR/servers/$1/server.properties | grep 'level-name=' | cut -d '=' -f2)
}







######## SERVER-RELATED FUNCTIONS

#### Check if a server exists (server name)

does_server_exist() {
    if [[ -d "$HOMEDIR/servers/$1" ]]; then
        echo "true"
    else
        echo "false"
    fi
}



#### Check if a server is running (server name)

is_server_running() {
    echo $(gorp -s $1 | jq .status[].running 2> /dev/null)
}



#### Get server's port (server name)

get_server_port() {
    echo $(cat $HOMEDIR/servers/$1/server.properties | grep 'server-port=' | cut -d '=' -f2)
}