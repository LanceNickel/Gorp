#!/usr/bin/env bash

### [JAR UPDATE WORKER] ############################################
#   Description:  Worker script that performs the jar update tasks.
#   Parameters:   1: (required) Server directory name
#   Global Conf:  GAMEVER

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################



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
    if $ERRORS; then echo "updatejar.sh: Not intended to be run directly. Exit (13)."; fi
    exit 13
fi







#### SCRIPT PARAMETERS ################

source /usr/local/bin/gorpmc/worker/i_getconfigparams.sh







####







### CLEAR TMP DIRECTORY

if [[ -d "$HOMEDIR/tmp" ]]; then rm -rf $HOMEDIR/tmp; fi
mkdir $HOMEDIR/tmp







### GET AND PROCESS JSON FOR LATEST STABLE PAPER BUILD

if $OUTPUT; then echo "Getting latest build information for $GAMEVER..."; fi

curl -s -X 'GET' "https://api.papermc.io/v2/projects/paper/versions/$GAMEVER/builds" -H 'accept: application/json' -o $HOMEDIR/tmp/builds.json







### VERSION NOT FOUND RT-GUARD

if [[ $(cat $HOMEDIR/tmp/builds.json | grep 'Version not found.') != "" ]]; then
    if $ERRORS; then echo "getjar.sh: Game version not found. Exit (60)."; fi
    exit 60
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
done







### STORE INFORMATION ABOUT LATEST STABLE BUILD AND CURRENTLY INSTALLED

INSTALLED=$(cat $HOMEDIR/jars/latest | cut -d "-" -f3 | cut -d "." -f1)
BUILD=$(jq '.build' $HOMEDIR/tmp/latest.json)
NAME=$(jq '.downloads.application.name' $HOMEDIR/tmp/latest.json | tail -c +2 | head -c -2)
CHECKSUM=$(jq '.downloads.application.sha256' $HOMEDIR/tmp/latest.json | tail -c +2 | head -c -2)







### DOWNLOAD THE LATEST JAR FILE

if $OUTPUT; then echo "Downloading latest stable jar file..."; fi

wget -q https://api.papermc.io/v2/projects/paper/versions/$GAMEVER/builds/$BUILD/downloads/$NAME -P $HOMEDIR/tmp/

if $OUTPUT; then echo "Installing build $BUILD over $INSTALLED..."; fi







### TEST THE CHECKSUM (RT-GUARD)

TESTSUM="$(sha256sum $HOMEDIR/tmp/$NAME | cut -d " " -f 1)"

if [[ $TESTSUM != $CHECKSUM ]]; then
        if $ERRORS; then echo "updatejar.sh: Downloaded JAR file failed checksum test. Exit (61)."; fi
        rm -rf $HOMEDIR/tmp
        exit 61
fi







### MOVE THE JAR TO THE $HOMEDIR/jars/ FOLDER AND MAKE IT EXECUTABLE

mv $HOMEDIR/tmp/$NAME $HOMEDIR/jars/
chmod +x $HOMEDIR/jars/$NAME







### UPDATE THE LATEST FILE FOR GLOBAL SERVER UPDATES

echo "$HOMEDIR/jars/$NAME" > $HOMEDIR/jars/latest







### CLEAN UP

rm -rf $HOMEDIR/tmp







if $OUTPUT; then echo "JAR updated! Changes won't take effect until a server restart."; fi
