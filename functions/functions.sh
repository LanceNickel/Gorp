#!/usr/bin/env bash

### [FUNCTIONS] ###################################################
#   Description: Generic functions to make code more modular.

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################

# Copyright (C) Lance Nickel 2026.
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
    if [[ -d "$HOMEDIR/servers/$1/world-$2" ]]; then
        echo "true"
    else
        echo "false"
    fi
}



#### Get server's active world (server name)

get_active_world() {
    echo $(cat $HOMEDIR/servers/$1/server.properties | grep 'level-name=' | cut -d '=' -f2 | cut -d '-' -f2-99)
}







######## SERVER-RELATED FUNCTIONS

#### Check if a server exists (server name)

does_server_exist() {
    if [[ "$1" == "" ]]; then
        echo "false"
    else
        if [[ -d "$HOMEDIR/servers/$1" ]]; then
            echo "true"
        else
            echo "false"
        fi
    fi
}



#### Check if a server is running (server name)

is_server_running() {
    if [[ $(screen -ls | grep "$1") != "" ]]; then
        echo "true"
    else
        echo "false"
    fi
}



#### Get server's port (server name)

get_server_port() {
    echo $(cat $HOMEDIR/servers/$1/server.properties | grep 'server-port=' | cut -d '=' -f2)
}



#### Get server's last started version

get_server_version() {
    echo $(cat $HOMEDIR/servers/$1/lastrunversion)
}



#### Stuff message to server

tell() {
    server="$1"
    message="$2"

    if [[ "$(does_server_exist $server)" == "true" ]] && [[ "$(is_server_running $server)" == "true" ]] && [[ "$message" != "" ]]; then

        if [[ "$SILENT_CHAT_MESSAGES" == "no" ]]; then
            screen -S "$server" -X stuff "say $message\n"
        else
            screen -S "$server" -X stuff "tellraw $message\n"
        fi

    fi
}



#### Get the current connected players on a server

get_connected_players() {
    if [[ "$1" == "" ]]; then
        echo "get_connected_players(): Invalid home directory"
        exit 1
    fi

    running="$(is_server_running $1)"

    if [[ "$running" == "false" ]]; then
        echo "0"
    fi

    if [[ "$running" == "true" ]]; then
        count="$(screen -S "$1" -X stuff "list\n" && sleep 0.1 && screen -S "$1" -X hardcopy "$HOMEDIR"/"$1".dump && tail -n2 "$HOMEDIR"/"$1".dump | head -n1 | grep -oP 'There are (\d+) of a max' | cut -d ' ' -f3)"
        echo "$count"
        rm "$HOMEDIR"/"$1".dump
    fi
}







######## CONFIGURATION FILE

#### Update config item

update_config() {
    key="$1"
    value="$2"
    
    if [[ "$key" == "" ]] || [[ "$value" == "" ]]; then
        echo "update_config() expects two parameters: key, value"
        exit 1
    fi

    sed -Ei "s:^$key=.*$:$key=$value:g" "$HOMEDIR"/gorp.conf
}







#### SAFETY FUNCTIONS ############

#### Calculate current allocated RAM

calculate_allocated_ram() {
    ALLOCATED=0

    for d in "$HOMEDIR/servers/"*
    do
        SERVER=$(echo $(basename "$d"))

        if [[ "$(is_server_running $SERVER)" == "true" ]]; then
            RUN_SAYS="$(grep -e '^CUSTOM_RAM=' $d/run.sh | cut -d '=' -f2)"

            if [[ "$RUN_SAYS" == '$RAM' ]]; then
                SERVER_RAM=$(echo $RAM | cut -d 'G' -f1)
            else
                SERVER_RAM=$(echo $RUN_SAYS | cut -d 'G' -f1)
            fi

            ALLOCATED=$(($SERVER_RAM+$ALLOCATED))
        fi
    done

    echo "$ALLOCATED"
}
