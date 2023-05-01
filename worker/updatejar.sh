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

curl -s -X 'GET' "https://api.papermc.io/v2/projects/paper/versions/$GAMEVER/builds" -H 'accept: application/json' -o /tmp/gorp/builds.json || handle_error "Failed to get build info"







### VERSION NOT FOUND RT-GUARD

if [[ $(cat /tmp/gorp/builds.json | grep 'Version not found.') != "" ]]; then
    handle_error "Game version not found"
fi







### DETERMINE THE LATEST BUILD NUMBER

jq '.builds[-1] | {build, channel, downloads}' /tmp/gorp/builds.json > /tmp/gorp/latest.json

FOUND=false
I=1

while [ $FOUND = false ];
do
        ((I++))
        # if the channel in latest.json is experimental...
        if [[ $(jq '.channel' /tmp/gorp/latest.json) != '"default"' ]]; then
                # get the second-oldest build version from builds.json and overwrite latest.json with it
                jq ".builds[-$I] | {build, channel, downloads}" /tmp/gorp/builds.json > /tmp/gorp/latest.json
        else
                # if the channel in latest.json is NOT experimental, we found the latest stable (default channel) version
                FOUND=true
        fi

        # pull from other




















done







### STORE INFORMATION ABOUT LATEST STABLE BUILD AND CURRENTLY INSTALLED

INSTALLED=$(cat $HOMEDIR/jars/latest | cut -d "-" -f3 | cut -d "." -f1)
BUILD=$(jq '.build' /tmp/gorp/latest.json)
NAME=$(jq '.downloads.application.name' /tmp/gorp/latest.json | tail -c +2 | head -c -2)
CHECKSUM=$(jq '.downloads.application.sha256' /tmp/gorp/latest.json | tail -c +2 | head -c -2)







### DOWNLOAD THE LATEST JAR FILE

echo "Downloading latest stable jar file..."

wget -q https://api.papermc.io/v2/projects/paper/versions/$GAMEVER/builds/$BUILD/downloads/$NAME -P /tmp/gorp/ || handle_error "Failed to download JAR file"

echo "Installing build $BUILD over $INSTALLED..."







### TEST THE CHECKSUM (RT-GUARD)

TESTSUM="$(sha256sum /tmp/gorp/$NAME | cut -d " " -f 1)"

if [[ $TESTSUM != $CHECKSUM ]]; then
        handle_error "Downloaded JAR file failed checksum test"
fi







### MOVE THE JAR TO THE $HOMEDIR/jars/ FOLDER AND MAKE IT EXECUTABLE

mv /tmp/gorp/$NAME $HOMEDIR/jars/ || handle_error "Failed to move JAR to jars folder"







### UPDATE THE LATEST FILE FOR GLOBAL SERVER UPDATES

echo "$HOMEDIR/jars/$NAME" > $HOMEDIR/jars/latest || handle_error "Failed to update latest JAR file"







echo "JAR updated! Changes won't take effect until a server restart."
