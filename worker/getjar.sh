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

        cd $HOMEDIR/tmp/ || handle_error "Failed to cd to $HOMEDIR/tmp"

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

        curl -s -X 'GET' "https://api.papermc.io/v2/projects/paper/versions/$ARG/builds" -H 'accept: application/json' -o $HOMEDIR/tmp/builds.json || handle_error "Failed to curl build info from https://api.papermc.io/v2/projects/paper/versions/$ARG/builds"







        ### VERSION NOT FOUND RT-GUARD

        if [[ $(cat $HOMEDIR/tmp/builds.json | grep 'Version not found.') != "" ]]; then
                handle_error "Game version not found."
        fi







        ### DETERMINE THE LATEST STABLE BUILD

        jq '.builds[-1] | {build, channel, downloads}' $HOMEDIR/tmp/builds.json > $HOMEDIR/tmp/latest.json

        FOUND=false
        I=1

        while [ $FOUND = false ]; do
                ((I++))
                # if the channel in latest.json is experimental...
                if [[ $(jq '.channel' $HOMEDIR/tmp/latest.json) != '"default"' ]]; then
                        # get the second-oldest build version from builds.json and overwrite latest.json with it
                        jq ".builds[-$I] | {build, channel, downloads}" $HOMEDIR/tmp/builds.json > $HOMEDIR/tmp/latest.json
                else
                        # if the channel in latest.json is NOT experimental, we found the latest stable (default channel) version
                        FOUND=true
                fi

                if [[ "$I" == "25" ]]; then
                        handle_error "Stable version not found, timeout."
                fi
        done







        ### STORE INFORMATION ABOUT BUILD TO DOWNLOAD

        BUILD=$(jq '.build' $HOMEDIR/tmp/latest.json)
        NAME=$(jq '.downloads.application.name' $HOMEDIR/tmp/latest.json | tail -c +2 | head -c -2)
        CHECKSUM=$(jq '.downloads.application.sha256' $HOMEDIR/tmp/latest.json | tail -c +2 | head -c -2)







        ### DOWNLOAD THE LATEST JAR FILE

        wget -q https://api.papermc.io/v2/projects/paper/versions/$ARG/builds/$BUILD/downloads/$NAME -P $HOMEDIR/tmp/ || handle_error "Failed to wget https://api.papermc.io/v2/projects/paper/versions/$ARG/builds/$BUILD/downloads/$NAME"







        ### TEST THE CHECKSUM (RT-GUARD)

        TESTSUM="$(sha256sum $HOMEDIR/tmp/$NAME | cut -d " " -f 1)"

        if [[ "$TESTSUM" != "$CHECKSUM" ]]; then
                handle_error "Downloaded JAR file failed checksum test."
        fi







        ### RENAME THE JAR, MOVE IT TO JARS, MAKE IT EXECUTABLE

        mv $HOMEDIR/tmp/$NAME /$HOMEDIR/tmp/$ARG.jar || handle_error "Failed to mv $HOMEDIR/tmp/$NAME to /$HOMEDIR/tmp/$ARG.jar"
        cp -f $HOMEDIR/tmp/$ARG.jar $HOMEDIR/jars/ || handle_error "Failed to cp $HOMEDIR/tmp/$ARG.jar to $HOMEDIR/jars/"
        chmod +x $HOMEDIR/jars/$ARG.jar || handle_error "Failed to +x $HOMEDIR/jars/$ARG.jar"







        echo -e "JAR file downloaded!\nPath: $HOMEDIR/jars/$ARG.jar"

fi
