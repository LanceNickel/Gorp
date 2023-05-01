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
    OUTPUT=true
    ERRORS=true

elif [[ "$1" == "pleaseshutup" ]]; then
    OUTPUT=false
    ERRORS=true

elif [[ "$1" == "pleasebesilent" ]]; then
    OUTPUT=false
    ERRORS=false

else
    if $ERRORS; then echo "getjar.sh: Not intended to be run directly. Exit (13)."; fi
    exit 13
fi






#### SCRIPT PARAMETERS ################

source /usr/local/bin/gorpmc/worker/i_getconfigparams.sh

MODE=$2
ARG=$3







####







####################    DOWNLOAD BY URL







if [[ "$MODE" == "u" ]]; then



        ### CLEAR TMP DIRECTORY

        rm -rf $HOMEDIR/tmp/
        mkdir $HOMEDIR/tmp/







        ### DOWNLOAD THE JAR

        if $OUTPUT; then echo "Downloading JAR file from URL..."; fi

        cd $HOMEDIR/tmp/

        wget -q $ARG


        # Verify download
        if [[ "$?" != "0" ]]; then
                if $ERRORS; then echo "getjar.sh: File download error, wget($?). Exit (62)."; fi
                exit 62
        fi







        ### SUCCESS, COPY & PRINT PATH

        FILENAME="$(echo $ARG | grep -o $(ls))"

        chmod +x ./$FILENAME
        cp ./$FILENAME $HOMEDIR/jars/

        if $OUTPUT; then echo -e "JAR file downloaded!\nPath: $HOMEDIR/jars/$FILENAME"; fi







        ### CLEAN UP

        rm -rf $HOMEDIR/tmp/
        
        
        
fi







####################    DOWNLOAD BY VERSION







if [[ "$MODE" == "g" ]]; then







        ### CLEAR TMP DIRECTORY

        rm -rf $HOMEDIR/tmp/
        mkdir $HOMEDIR/tmp/







        ### GET AND PROCESS JSON FOR LATEST STABLE PAPER BUILD

        if $OUTPUT; then echo "Downloading Paper $ARG..."; fi

        curl -s -X 'GET' "https://api.papermc.io/v2/projects/paper/versions/$ARG/builds" -H 'accept: application/json' -o $HOMEDIR/tmp/builds.json







        ### VERSION NOT FOUND RT-GUARD

        if [[ $(cat $HOMEDIR/tmp/builds.json | grep 'Version not found.') != "" ]]; then
                if $ERRORS; then echo "getjar.sh: Game version not found. Exit (60)."; fi
                exit 60
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
                if $ERRORS; then echo "getjar.sh: Downloaded JAR file failed checksum test. Exit (61)."; fi
                rm -rf $HOMEDIR/tmp
                exit 61
        fi







        ### RENAME THE JAR, MOVE IT TO JARS, MAKE IT EXECUTABLE

        mv $HOMEDIR/tmp/$NAME /$HOMEDIR/tmp/$ARG.jar
        cp -f $HOMEDIR/tmp/$ARG.jar $HOMEDIR/jars/
        chmod +x $HOMEDIR/jars/$ARG.jar







        ### CLEAN UP

        rm -rf $HOMEDIR/tmp







        if $OUTPUT; then echo -e "JAR file downloaded!\nPath: $HOMEDIR/jars/$ARG.jar"; fi

fi
