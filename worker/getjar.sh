#!/usr/bin/env bash

### [JAR DOWNLOAD WORKER] ##########################################
#   Description:  Worker script that performs the update tasks.
#   Parameters:   1: (required) Game version

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################

# Copyright (C) Lance Nickel 2023.
# Distributed under GNU GPL v3.
# <https://gorp.lanickel.com/license/>



#### GUARDS ################

### KEY GUARD

if [[ "$1" == "pleasedontdothis" ]]; then
    handle_error "Script not meant to be run directly."
fi






#### SCRIPT PARAMETERS ################

MODE=$2
ARG=$3







####







####################    DOWNLOAD BY URL







if [[ "$MODE" == "u" ]]; then







        ### DOWNLOAD THE JAR

        echo "Downloading JAR file from URL..."

        cd /tmp/gorp/ || handle_error "Failed to cd to /tmp/gorp"

        wget -q $ARG || handle_error "Failed to wget $ARG"







        ### SUCCESS, COPY & PRINT PATH

        FILENAME="$(echo $ARG | grep -o $(ls))"

        chmod +x ./$FILENAME || handle_error "Failed to +x $FILENAME"
        cp ./$FILENAME $HOMEDIR/jars/ || handle_error "Failed to cp $FILENAME to $HOMEDIR/jars/"

        echo -e "JAR file downloaded!\nPath: $HOMEDIR/jars/$FILENAME"
        
        
        
fi







####################    DOWNLOAD BY VERSION







if [[ "$MODE" == "g" ]]; then







        ### GET AND PROCESS JSON FOR LATEST STABLE PAPER BUILD

        echo "Downloading Paper $ARG..."

        curl -s -X 'GET' "https://api.papermc.io/v2/projects/paper/versions/$ARG/builds" -H 'accept: application/json' -o /tmp/gorp/builds.json || handle_error "Failed to curl build info from https://api.papermc.io/v2/projects/paper/versions/$ARG/builds"







        ### VERSION NOT FOUND RT-GUARD

        if [[ $(cat /tmp/gorp/builds.json | grep 'Version not found.') != "" ]]; then
                handle_error "Game version not found."
        fi







        ### DETERMINE THE LATEST STABLE BUILD

        jq '.builds[-1] | {build, channel, downloads}' /tmp/gorp/builds.json > /tmp/gorp/latest.json

        FOUND=false
        I=1

        while [ $FOUND = false ]; do
                ((I++))
                # if the channel in latest.json is experimental...
                if [[ $(jq '.channel' /tmp/gorp/latest.json) != '"default"' ]]; then
                        # get the second-oldest build version from builds.json and overwrite latest.json with it
                        jq ".builds[-$I] | {build, channel, downloads}" /tmp/gorp/builds.json > /tmp/gorp/latest.json
                else
                        # if the channel in latest.json is NOT experimental, we found the latest stable (default channel) version
                        FOUND=true
                fi

                if [[ "$I" == "25" ]]; then
                        handle_error "Stable version not found, timeout."
                fi
        done







        ### STORE INFORMATION ABOUT BUILD TO DOWNLOAD

        BUILD=$(jq '.build' /tmp/gorp/latest.json)
        NAME=$(jq '.downloads.application.name' /tmp/gorp/latest.json | tail -c +2 | head -c -2)
        CHECKSUM=$(jq '.downloads.application.sha256' /tmp/gorp/latest.json | tail -c +2 | head -c -2)







        ### DOWNLOAD THE LATEST JAR FILE

        wget -q https://api.papermc.io/v2/projects/paper/versions/$ARG/builds/$BUILD/downloads/$NAME -P /tmp/gorp/ || handle_error "Failed to wget https://api.papermc.io/v2/projects/paper/versions/$ARG/builds/$BUILD/downloads/$NAME"







        ### TEST THE CHECKSUM (RT-GUARD)

        TESTSUM="$(sha256sum /tmp/gorp/$NAME | cut -d " " -f 1)"

        if [[ "$TESTSUM" != "$CHECKSUM" ]]; then
                handle_error "Downloaded JAR file failed checksum test."
        fi







        ### RENAME THE JAR, MOVE IT TO JARS, MAKE IT EXECUTABLE

        mv /tmp/gorp/$NAME /tmp/gorp/$ARG.jar || handle_error "Failed to mv /tmp/gorp/$NAME to //tmp/gorp/$ARG.jar"
        cp -f /tmp/gorp/$ARG.jar $HOMEDIR/jars/ || handle_error "Failed to cp /tmp/gorp/$ARG.jar to $HOMEDIR/jars/"
        chmod +x $HOMEDIR/jars/$ARG.jar || handle_error "Failed to +x $HOMEDIR/jars/$ARG.jar"







        echo -e "JAR file downloaded!\nPath: $HOMEDIR/jars/$ARG.jar"

fi
