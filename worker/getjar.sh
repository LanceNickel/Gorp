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



        ### CLEAR TMP DIRECTORY

        rm -rf $HOMEDIR/tmp/
        mkdir $HOMEDIR/tmp/







        ### DOWNLOAD THE JAR

        echo "Downloading JAR file from URL..."

        cd $HOMEDIR/tmp/

        wget -q $ARG


        # Verify download
        if [[ "$?" != "0" ]]; then
                handle_error "File download error, wget($?)."
        fi







        ### SUCCESS, COPY & PRINT PATH

        FILENAME="$(echo $ARG | grep -o $(ls))"

        chmod +x ./$FILENAME
        cp ./$FILENAME $HOMEDIR/jars/

        echo -e "JAR file downloaded!\nPath: $HOMEDIR/jars/$FILENAME"







        ### CLEAN UP

        rm -rf $HOMEDIR/tmp/
        
        
        
fi







####################    DOWNLOAD BY VERSION







if [[ "$MODE" == "g" ]]; then







        ### CLEAR TMP DIRECTORY

        rm -rf $HOMEDIR/tmp/
        mkdir $HOMEDIR/tmp/







        ### GET AND PROCESS JSON FOR LATEST STABLE PAPER BUILD

        echo "Downloading Paper $ARG..."

        curl -s -X 'GET' "https://api.papermc.io/v2/projects/paper/versions/$ARG/builds" -H 'accept: application/json' -o $HOMEDIR/tmp/builds.json







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
        done







        ### STORE INFORMATION ABOUT BUILD TO DOWNLOAD

        BUILD=$(jq '.build' $HOMEDIR/tmp/latest.json)
        NAME=$(jq '.downloads.application.name' $HOMEDIR/tmp/latest.json | tail -c +2 | head -c -2)
        CHECKSUM=$(jq '.downloads.application.sha256' $HOMEDIR/tmp/latest.json | tail -c +2 | head -c -2)







        ### DOWNLOAD THE LATEST JAR FILE

        wget -q https://api.papermc.io/v2/projects/paper/versions/$ARG/builds/$BUILD/downloads/$NAME -P $HOMEDIR/tmp/







        ### TEST THE CHECKSUM (RT-GUARD)

        TESTSUM="$(sha256sum $HOMEDIR/tmp/$NAME | cut -d " " -f 1)"

        if [[ "$TESTSUM" != "$CHECKSUM" ]]; then
                handle_error "Downloaded JAR file failed checksum test."
        fi







        ### RENAME THE JAR, MOVE IT TO JARS, MAKE IT EXECUTABLE

        mv $HOMEDIR/tmp/$NAME /$HOMEDIR/tmp/$ARG.jar
        cp -f $HOMEDIR/tmp/$ARG.jar $HOMEDIR/jars/
        chmod +x $HOMEDIR/jars/$ARG.jar







        ### CLEAN UP

        rm -rf $HOMEDIR/tmp







        echo -e "JAR file downloaded!\nPath: $HOMEDIR/jars/$ARG.jar"

fi
