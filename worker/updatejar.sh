#!/usr/bin/env bash

### [JAR UPDATE WORKER] ############################################
#   Description:  Worker script that performs the jar update tasks.
#   Parameters:   1: (required) Server directory name
#   Global Conf:  GAMEVER

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################



# PERMISSIONS GUARD

if [[ "$EUID" != 0 ]]; then
    echo "updatejar.sh: Insufficient privilege. Exiting."
    exit
fi



# SCRIPT VARIABLES

GAMEVER=$(cat $HOMEDIR/gorp.conf | grep "^[^#;]" | grep 'GAMEVER=' | cut -d '=' -f 2)



####



# CLEAR TMP DIRECTORY

if [ -d "$HOMEDIR/tmp" ]; then rm -rf $HOMEDIR/tmp; fi
mkdir $HOMEDIR/tmp



# GET AND PROCESS JSON FOR LATEST STABLE PAPER BUILD

echo "updatejar.sh: Getting latest build information for $GAMEVER..."

curl -s -X 'GET' "https://api.papermc.io/v2/projects/paper/versions/$GAMEVER/builds" -H 'accept: application/json' -o $HOMEDIR/tmp/builds.json



# VERSION NOT FOUND GUARD

if [[ $(cat $HOMEDIR/tmp/builds.json | grep 'Version not found.') != "" ]]; then
    echo "getjar.sh: Specified game version not found. Exiting."
    exit
fi



# DETERMINE THE LATEST BUILD NUMBER

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
done



# STORE INFORMATION ABOUT LATEST STABLE BUILD AND CURRENTLY INSTALLED

INSTALLED=$(cat $HOMEDIR/jars/latest | cut -d "-" -f3 | cut -d "." -f1)
BUILD=$(jq '.build' $HOMEDIR/tmp/latest.json)
NAME=$(jq '.downloads.application.name' $HOMEDIR/tmp/latest.json | tail -c +2 | head -c -2)
CHECKSUM=$(jq '.downloads.application.sha256' $HOMEDIR/tmp/latest.json | tail -c +2 | head -c -2)



# DOWNLOAD THE LATEST JAR FILE

echo "updatejar.sh: Downloading latest stable jar file..."

wget -q https://api.papermc.io/v2/projects/paper/versions/$GAMEVER/builds/$BUILD/downloads/$NAME -P $HOMEDIR/tmp/

echo "updatejar.sh: Installing build $BUILD over $INSTALLED..."



# TEST THE CHECKSUM (GUARD)

TESTSUM="$(sha256sum $HOMEDIR/tmp/$NAME | cut -d " " -f 1)"

if [ $TESTSUM != $CHECKSUM ]; then
        echo "updatejar.sh: Checksum comparison of download failed. This is a security risk. Exiting."
        rm -rf $HOMEDIR/tmp
        exit
fi



# MOVE THE JAR TO THE $HOMEDIR/jars/ FOLDER AND MAKE IT EXECUTABLE

echo "updatejar.sh: Setting jar file as new global default..."

mv $HOMEDIR/tmp/$NAME $HOMEDIR/jars/
chmod +x $HOMEDIR/jars/$NAME



# UPDATE THE LATEST FILE FOR GLOBAL SERVER UPDATES

echo "$HOMEDIR/jars/$NAME" > $HOMEDIR/jars/latest



# CLEAN UP

rm -rf $HOMEDIR/tmp



echo "updatejar.sh: Update complete. Changes won't take effect until a server restart."
