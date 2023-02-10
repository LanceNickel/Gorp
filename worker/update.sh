#!/usr/bin/env bash

### [UPDATE WORKER] ################################################
#   Description:  Worker script that performs the update tasks.
#   Parameters:   1: (required) Server directory name
#   Global Conf:  GAMEVER

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################



# PERMISSIONS GUARD

if [[ "$EUID" != 0 ]]; then
    echo "update.sh: Insufficient privilege. Exiting."
    exit
fi



# SCRIPT VARIABLES

$GAMEVER=$(cat /minecraft/gorp.conf | grep "^[^#;]" | grep 'GAMEVER=' | cut -d '=' -f 2)



####



# CLEAR TMP DIRECTORY

if [ -d "/minecraft/tmp" ]; then rm -rf /minecraft/tmp; fi
mkdir /minecraft/tmp



# GET AND PROCESS JSON FOR LATEST STABLE PAPER BUILD

echo "update.sh: Getting latest build information for $GAMEVER..."

curl -s -X 'GET' "https://api.papermc.io/v2/projects/paper/versions/$GAMEVER/builds" -H 'accept: application/json' -o /minecraft/tmp/builds.json
jq '.builds[-1] | {build, channel, downloads}' /minecraft/tmp/builds.json > /minecraft/tmp/latest.json



# DETERMINE THE LATEST BUILD NUMBER

FOUND=false
I=1

while [ $FOUND = false ];
do
        ((I++))
        # if the channel in latest.json is experimental...
        if [[ $(jq '.channel' /minecraft/tmp/latest.json) != '"default"' ]]; then
                # get the second-oldest build version from builds.json and overwrite latest.json with it
                jq ".builds[-$I] | {build, channel, downloads}" /minecraft/tmp/builds.json > /minecraft/tmp/latest.json
        else
                # if the channel in latest.json is NOT experimental, we found the latest stable (default channel) version
                FOUND=true
        fi
done



# STORE INFORMATION ABOUT LATEST STABLE BUILD AND CURRENTLY INSTALLED

INSTALLED=$(cat /minecraft/jars/latest | cut -d "-" -f3 | cut -d "." -f1)
BUILD=$(jq '.build' /minecraft/tmp/latest.json)
NAME=$(jq '.downloads.application.name' /minecraft/tmp/latest.json | tail -c +2 | head -c -2)
CHECKSUM=$(jq '.downloads.application.sha256' /minecraft/tmp/latest.json | tail -c +2 | head -c -2)



# DO WE EVEN NEED TO UPDATE?

echo "update.sh: Installing build $BUILD over $INSTALLED..."



# DOWNLOAD THE LATEST JAR FILE

echo "update.sh: Downloading latest stable jar file..."

wget -q https://api.papermc.io/v2/projects/paper/versions/$GAMEVER/builds/$BUILD/downloads/$NAME -P /minecraft/tmp/



# TEST THE CHECKSUM (GUARD)

TESTSUM="$(sha256sum /minecraft/tmp/$NAME | cut -d " " -f 1)"

if [ $TESTSUM != $CHECKSUM ]; then
        echo "update.sh: Checksum comparison of download failed. This is a security risk. Exiting."
        rm -rf /minecraft/tmp
        exit
fi



# MOVE THE JAR TO THE /minecraft/jars/ FOLDER AND MAKE IT EXECUTABLE

echo "update.sh: Setting jar file as new global default..."

mv /minecraft/tmp/$NAME /minecraft/jars/
chmod +x /minecraft/jars/$NAME



# UPDATE THE LATEST FILE FOR GLOBAL SERVER UPDATES

echo "/minecraft/jars/$NAME" > /minecraft/jars/latest



# CLEAN UP

rm -rf /minecraft/tmp



echo "update.sh: Update complete. Changes won't take effect until a server restart."
