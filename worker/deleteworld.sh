#!/usr/bin/env bash

### [DELETE-WORLD WORKER] #########################################
#   Description:  Worker script that performs the world delete.
#   Parameters:   1: (required) Server directory name
#                 2: (optional) World (level) name for directory

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################



# PERMISSIONS GUARD

if [[ "$EUID" != 0 ]]; then
        echo "deleteworld.sh: Insufficient privilege. Exiting."
        exit
fi



# SCRIPT VARIABLES

SERVER=$1
WORLD_TO_DELETE=$2

OPTIONS=$(ls $HOMEDIR/servers/$SERVER/ | grep '_nether' | cut -d '-' -f2 | cut -d '_' -f1)



####



# IF WORLD_TO_DELETE NOT SPECIFIED, ASK USER

if [ "$WORLD_TO_DELETE" == "" ]; then
    while [ true ]
    do
        echo -e "Options:\n$OPTIONS"

        read -r -p "Please enter a world to delete: " response

        TEST=$(echo $OPTIONS | grep -w $response)

        if [[ "$TEST" != "" ]]; then
            WORLD_TO_DELETE=$response
            break
        else
            echo -e "\nSpecified world does not exist.\n"
        fi
    done
fi



# USER CONFIRMATION GUARDS

echo "You are about to delete a world named '$WORLD_TO_DELETE' in the '$SERVER' server instance."

read -r -p "Did you back up the world? [y/n] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    sleep 0.005
else
    echo "PLEASE BACK UP YOUR WORLD FILES! Run 'mcbackup $SERVER' to take a back up first."
    exit
fi

read -r -p "Enter '$WORLD_TO_DELETE' to confirm: " response
if [[ "$response" == "$WORLD_TO_DELETE" ]]; then
    sleep 0.5
else
    echo "Incorrect response. Exiting."
    exit
fi



# DELETE THE WORLD

rm -rf $HOMEDIR/servers/$SERVER/world-$WORLD_TO_DELETE
rm -rf $HOMEDIR/servers/$SERVER/world-${WORLD_TO_DELETE}_nether
rm -rf $HOMEDIR/servers/$SERVER/world-${WORLD_TO_DELETE}_the_end



echo "deleteworld.sh: World deleted."