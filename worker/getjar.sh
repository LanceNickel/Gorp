#!/usr/bin/env bash

### [JAR DOWNLOAD WORKER] ##########################################
#   Description:  Worker script that performs the update tasks.
#   Parameters:   1: (required) Game version

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################



# PERMISSIONS GUARD

if [[ "$EUID" != 0 ]]; then
    echo "getjar.sh: Insufficient privilege. Exiting."
    exit
fi



# SCRIPT VARIABLES

VERSION=$1



####



# CLEAR TMP DIRECTORY

if [ -d "/minecraft/tmp" ]; then rm -rf /minecraft/tmp; fi
mkdir /minecraft/tmp



# GET AND PROCESS JSON FOR LATEST STABLE PAPER BUILD

echo "getjar.sh: Getting latest build information for $VERSION..."

curl -s -X 'GET' "https://api.papermc.io/v2/projects/paper/versions/$VERSION/builds" -H 'accept: application/json' -o /minecraft/tmp/builds.json



# VERSION NOT FOUND GUARD

if [[ $(cat /minecraft/tmp/builds.json | grep 'Version not found.') != "" ]]; then
    echo "getjar.sh: Specified game version not found. Exiting."
    exit
fi



# DETERMINE THE LATEST STABLE BUILD

jq '.builds[-1] | {build, channel, downloads}' /minecraft/tmp/builds.json > /minecraft/tmp/latest.json

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



# STORE INFORMATION ABOUT BUILD TO DOWNLOAD

BUILD=$(jq '.build' /minecraft/tmp/latest.json)
NAME=$(jq '.downloads.application.name' /minecraft/tmp/latest.json | tail -c +2 | head -c -2)
CHECKSUM=$(jq '.downloads.application.sha256' /minecraft/tmp/latest.json | tail -c +2 | head -c -2)



# DOWNLOAD THE LATEST JAR FILE

echo "getjar.sh: Downloading latest stable jar file..."

wget -q https://api.papermc.io/v2/projects/paper/versions/$VERSION/builds/$BUILD/downloads/$NAME -P /minecraft/tmp/



# TEST THE CHECKSUM (GUARD)

TESTSUM="$(sha256sum /minecraft/tmp/$NAME | cut -d " " -f 1)"

if [ $TESTSUM != $CHECKSUM ]; then
        echo "getjar.sh: Checksum comparison of download failed. This is a security risk. Exiting."
        rm -rf /minecraft/tmp
        exit
fi



# MOVE THE JAR TO THE /minecraft/jars/ FOLDER AND MAKE IT EXECUTABLE

echo "getjar.sh: Setting jar file as new global default..."

mv /minecraft/tmp/$NAME /minecraft/jars/
chmod +x /minecraft/jars/$NAME



# UPDATE THE LATEST FILE FOR GLOBAL SERVER UPDATES

echo "/minecraft/jars/$NAME" > /minecraft/jars/latest



# CLEAN UP

rm -rf /minecraft/tmp



echo -e "getjar.sh: Download complete. Individual instances must be customized to use this JAR version over the globally set version.\nLearn more: https://gorp.lanickel.com/custom-jar.html"
