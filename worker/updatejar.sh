#!/usr/bin/env bash

### [JAR UPDATE WORKER] ############################################
#   Description:  Worker script that performs the jar update tasks.
#   Parameters:   1: (required) Server directory name
#   Global Conf:  GAMEVER

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







####







### GET AND PROCESS JSON FOR LATEST STABLE PAPER BUILD

echo "Getting latest build information for $GAMEVER..."

curl -s -X 'GET' "https://api.papermc.io/v2/projects/paper/versions/$GAMEVER/builds" -H 'accept: application/json' -o $HOMEDIR/tmp/builds.json || handle_error "Failure to get build info from https://api.papermc.io/v2/projects/paper/versions/$GAMEVER/builds"







### VERSION NOT FOUND RT-GUARD

if [[ $(cat $HOMEDIR/tmp/builds.json | grep 'Version not found.') != "" ]]; then
    handle_error "Game version not found."
fi







### DETERMINE THE LATEST BUILD NUMBER

jq '.builds[-1] | {build, channel, downloads}' $HOMEDIR/tmp/builds.json > $HOMEDIR/tmp/latest.json

FOUND=false
I=1

while [ $FOUND = false ];
do
        ((I++))
        # if the channel in latest.json is experimental...
        if [[ $(jq '.channel' $HOMEDIR/tmp/latest.json) != '"default"' ]]; then
                # get the second-oldest build version from builds.json and overwrite latest.json with it
                jq ".builds[-$I] | {build, channel, downloads}" $HOMEDIR/tmp/builds.json > $HOMEDIR/tmp/latest.json
        else
                # if the channel in latest.json is NOT experimental, we found the latest stable (default channel) version
                FOUND=true
        fi

        # pull from other




















done







### STORE INFORMATION ABOUT LATEST STABLE BUILD AND CURRENTLY INSTALLED

INSTALLED=$(cat $HOMEDIR/jars/latest | cut -d "-" -f3 | cut -d "." -f1)
BUILD=$(jq '.build' $HOMEDIR/tmp/latest.json)
NAME=$(jq '.downloads.application.name' $HOMEDIR/tmp/latest.json | tail -c +2 | head -c -2)
CHECKSUM=$(jq '.downloads.application.sha256' $HOMEDIR/tmp/latest.json | tail -c +2 | head -c -2)







### DOWNLOAD THE LATEST JAR FILE

echo "Downloading latest stable jar file..."

wget -q https://api.papermc.io/v2/projects/paper/versions/$GAMEVER/builds/$BUILD/downloads/$NAME -P $HOMEDIR/tmp/ || handle_error "Failed to wget https://api.papermc.io/v2/projects/paper/versions/$GAMEVER/builds/$BUILD/downloads/$NAME"

echo "Installing build $BUILD over $INSTALLED..."







### TEST THE CHECKSUM (RT-GUARD)

TESTSUM="$(sha256sum $HOMEDIR/tmp/$NAME | cut -d " " -f 1)"

if [[ $TESTSUM != $CHECKSUM ]]; then
        handle_error "updatejar.sh: Downloaded JAR file failed checksum test."
fi







### MOVE THE JAR TO THE $HOMEDIR/jars/ FOLDER AND MAKE IT EXECUTABLE

mv $HOMEDIR/tmp/$NAME $HOMEDIR/jars/ || handle_error "Failed to mv $HOMEDIR/tmp/$NAME to $HOMEDIR/jars/"







### UPDATE THE LATEST FILE FOR GLOBAL SERVER UPDATES

echo "$HOMEDIR/jars/$NAME" > $HOMEDIR/jars/latest || handle_error "Failed to update latest JAR file."







echo "JAR updated! Changes won't take effect until a server restart."
