#!/usr/bin/env bash

### [JAR DOWNLOAD WORKER] ##########################################
#   Description:  Worker script that performs the update tasks.
#   Parameters:   1: (required) Game version

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################



#### GUARDS ################

### KEY GUARD

if [[ "$1" != "pleasedontdothis" ]]; then
    echo "getjar.sh: Not intended to be run directly. Exit (13)."
    exit 13
fi



#### SCRIPT PARAMETERS ################

source /usr/local/bin/gorpmc/worker/i_getconfigparams.sh

VERSION=$2



####



# CLEAR TMP DIRECTORY

rm -rf $HOMEDIR/tmp
mkdir $HOMEDIR/tmp



# GET AND PROCESS JSON FOR LATEST STABLE PAPER BUILD

echo "Getting latest build information for $VERSION..."

curl -s -X 'GET' "https://api.papermc.io/v2/projects/paper/versions/$VERSION/builds" -H 'accept: application/json' -o $HOMEDIR/tmp/builds.json



# VERSION NOT FOUND RT-GUARD

if [[ $(cat $HOMEDIR/tmp/builds.json | grep 'Version not found.') != "" ]]; then
    echo "getjar.sh: Game version not found. Exit (60)."
    exit 60
fi



# DETERMINE THE LATEST STABLE BUILD

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



# STORE INFORMATION ABOUT BUILD TO DOWNLOAD

BUILD=$(jq '.build' $HOMEDIR/tmp/latest.json)
NAME=$(jq '.downloads.application.name' $HOMEDIR/tmp/latest.json | tail -c +2 | head -c -2)
CHECKSUM=$(jq '.downloads.application.sha256' $HOMEDIR/tmp/latest.json | tail -c +2 | head -c -2)



# DOWNLOAD THE LATEST JAR FILE

echo "Downloading latest stable jar file..."

wget -q https://api.papermc.io/v2/projects/paper/versions/$VERSION/builds/$BUILD/downloads/$NAME -P $HOMEDIR/tmp/



# TEST THE CHECKSUM (RT-GUARD)

TESTSUM="$(sha256sum $HOMEDIR/tmp/$NAME | cut -d " " -f 1)"

if [[ $TESTSUM != $CHECKSUM ]]; then
        echo "getjar.sh: Downloaded JAR file failed checksum test. Exit (61)."
        rm -rf $HOMEDIR/tmp
        exit 61
fi



# RENAME THE JAR, MOVE IT TO JARS, MAKE IT EXECUTABLE

mv $HOMEDIR/tmp/$NAME /$HOMEDIR/tmp/$VERSION.jar
cp -f $HOMEDIR/tmp/$VERSION.jar $HOMEDIR/jars/
chmod +x $HOMEDIR/jars/$VERSION.jar



# CLEAN UP

rm -rf $HOMEDIR/tmp



echo -e "JAR downloaded! Individual instances must be customized to use this JAR version over the globally set version.\nLearn more: https://gorp.lanickel.com/manage-instances/instance-settings/"
