#!/usr/bin/env bash

### [JAR DOWNLOAD WORKER] ##########################################
#   Description:  Worker script that performs the update tasks.
#   Parameters:   1: (required) Game version

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

MODE=$2
ARG=$3







####







#### DOWNLOAD BY URL ############

if [[ "$MODE" == "-u" ]]; then

        #### Download the JAR

        echo "Downloading JAR file from URL..."
        cd /tmp/gorp/ || handle_error "Failed to cd to /tmp/gorp."
        wget -q $ARG || handle_error "Failed to download passed URL."



        #### Move to JARS and print file name

        FILENAME="$(echo $ARG | grep -o $(ls))"
        cp ./$FILENAME $HOMEDIR/jars/ || handle_error "Failed to copy downloaded file to jars directory."
        echo -e "JAR file downloaded!\nPath: $HOMEDIR/jars/$FILENAME"
         
fi







#### DOWNLOAD BY GAMEVER ############

if [[ "$MODE" == "-g" ]]; then

        #### Get build info

        echo "Getting build information..."
        curl -s -X 'GET' "https://api.papermc.io/v2/projects/paper/versions/$ARG/builds" -H 'accept: application/json' -o /tmp/gorp/builds.json || handle_error "Failed to get latest build info."



        #### Gamever not found

        if [[ $(cat /tmp/gorp/builds.json | grep 'Version not found.') != "" ]]; then
                handle_error "Game version not found."
        fi



        #### Find latest stable build

        jq '.builds[-1] | {build, channel, downloads}' /tmp/gorp/builds.json > /tmp/gorp/latest.json || handle_error "Failed to parse build information."

        FOUND=false
        I=1

        while [ $FOUND = false ]; do
                ((I++))

                # If the channel in latest.json is experimental...
                if [[ $(jq '.channel' /tmp/gorp/latest.json) != '"default"' ]]; then
                        
                        # Get the second-oldest build version from builds.json and overwrite latest.json with it
                        jq ".builds[-$I] | {build, channel, downloads}" /tmp/gorp/builds.json > /tmp/gorp/latest.json
                else
                        
                        # If the channel in latest.json is NOT experimental, we found the latest stable (default channel) version
                        FOUND=true
                fi

                if [[ "$I" == "25" ]]; then
                        handle_error "Stable version not found, timeout."
                fi
        done







        #### PARSE LATEST BUILD INFO ############

        BUILD=$(jq '.build' /tmp/gorp/latest.json)
        NAME=$(jq '.downloads.application.name' /tmp/gorp/latest.json | tail -c +2 | head -c -2)
        CHECKSUM=$(jq '.downloads.application.sha256' /tmp/gorp/latest.json | tail -c +2 | head -c -2)







        #### DOWNLOAD THE BUILD ############

        wget -q https://api.papermc.io/v2/projects/paper/versions/$ARG/builds/$BUILD/downloads/$NAME -P /tmp/gorp/ || handle_error "Failed to download JAR file."



        #### Test checksum

        TESTSUM="$(sha256sum /tmp/gorp/$NAME | cut -d " " -f 1)"

        if [[ "$TESTSUM" != "$CHECKSUM" ]]; then
                handle_error "Downloaded JAR file failed checksum test."
        fi



        #### Rename the JAR and move it to the jars folder

        mv /tmp/gorp/$NAME /tmp/gorp/$ARG.jar || handle_error "Failed to rename JAR file."
        cp -f /tmp/gorp/$ARG.jar $HOMEDIR/jars/ || handle_error "Failed to move JAR to jars directory."
        
        
        
        #### Done
        
        echo -e "JAR file downloaded!\nPath: $HOMEDIR/jars/$ARG.jar"

fi
