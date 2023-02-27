#!/usr/bin/env bash

### [CREATE-WORLD WORKER] #########################################
#   Description:  Worker script that performs the new world tasks.
#   Parameters:   1: (required) Server directory name
#                 2: (optional) World (level) name for directory

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################



#### GUARDS ################

### KEY GUARD

if [[ "$1" != "pleasedontdothis" ]]; then
    echo "createworld.sh: Not intended to be run directly. Exit (13)."
    exit 13
fi



#### SCRIPT PARAMETERS ################

SERVER=$2
NEW_WORLD=$3

OLD_WORLD=$(cat $HOMEDIR/servers/$SERVER/server.properties | grep 'level-name=' | cut -d '=' -f2)



####



# IF NEW_WORLD NOT SPECIFIED THEN ASK USER

if [[ "$NEW_WORLD" == "" ]]; then

        while [ true ]
        do
                read -r -p "Enter a new world name: " response

                if [[ -d "$HOMEDIR/servers/$SERVER/world-$response" ]]; then
                        echo "A world with this name already exists."
                else
                        NEW_WORLD=$response
                        break
                fi
        done

fi



# UPDATE 'level-name' IN 'server.properties' AND START/STOP SERVER TO GENERATE WORLD FILES

echo "createworld.sh: Updating server config and generating new world... (This will take ~1m)"

sed -i "s/level-name=$OLD_WORLD/level-name=world-$NEW_WORLD/" $HOMEDIR/servers/$SERVER/server.properties

/usr/local/bin/gorpmc/action/mcstart pleasedontdothis $SERVER > /dev/null

sleep 30

/usr/local/bin/gorpmc/action/mcstop pleasedontdothis $SERVER now > /dev/null



# TAKE INITIAL BACKUP OF WORLD...

echo "createworld.sh: Taking initial backup of the new world..."

/usr/local/bin/gorpmc/action/mcbackupworld pleasedontdothis $SERVER > /dev/null



echo "createworld.sh: New world created. Start the server to begin exploring!"