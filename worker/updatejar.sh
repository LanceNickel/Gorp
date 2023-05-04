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



#### SETUP ############

#### Key guard

if [[ "$1" == "pleasedontdothis" ]]; then
    handle_error "Script not meant to be run directly."
fi



#### Globals

source /usr/local/bin/gorpmc/functions/exit.sh
source /usr/local/bin/gorpmc/functions/params.sh
source /usr/local/bin/gorpmc/functions/functions.sh







####







#### GUARDS ############

#### Get build info

echo "Getting latest build information for $GAMEVER..."
curl -s -X 'GET' "https://api.papermc.io/v2/projects/paper/versions/$GAMEVER/builds" -H 'accept: application/json' -o /tmp/gorp/builds.json || handle_error "Failed to get build info"



#### Gamever not found

if [[ $(cat /tmp/gorp/builds.json | grep 'Version not found.') != "" ]]; then
    handle_error "Game version not found"
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
                handle_error "Stable version not found, timeout"
        fi
done







#### GET INST. VERSION && PARSE LATEST BUILD INFO ############

INSTALLED=$(cat $HOMEDIR/jars/latest | cut -d "-" -f3 | cut -d "." -f1)
BUILD=$(jq '.build' /tmp/gorp/latest.json)
NAME=$(jq '.downloads.application.name' /tmp/gorp/latest.json | tail -c +2 | head -c -2)
CHECKSUM=$(jq '.downloads.application.sha256' /tmp/gorp/latest.json | tail -c +2 | head -c -2)







#### DOWNLOAD THE BUILD ############

echo "Downloading latest stable jar file..."
wget -q https://api.papermc.io/v2/projects/paper/versions/$GAMEVER/builds/$BUILD/downloads/$NAME -P /tmp/gorp/ || handle_error "Failed to download JAR file"



#### Test checksum

TESTSUM="$(sha256sum /tmp/gorp/$NAME | cut -d " " -f 1)"

if [[ $TESTSUM != $CHECKSUM ]]; then
        handle_error "Downloaded JAR file failed checksum test"
fi







#### INSTALL ############

#### Move JAR to jars

echo "Installing build $BUILD over $INSTALLED..."
mv /tmp/gorp/$NAME $HOMEDIR/jars/ || handle_error "Failed to move JAR to jars folder"



#### Update latest jar file

echo "$HOMEDIR/jars/$NAME" > $HOMEDIR/jars/latest || handle_error "Failed to update latest JAR file"







#### WE MADE IT ############

echo "JAR updated! Changes won't take effect until a server restart."