#!/usr/bin/env bash

# THIS IS THE UPDATE SCRIPT!
# This is a utility function (ends in .sh), it should not be called directly by the command line user.
# This should not need to be updated outside of updates to functionality of the program itself.

# PARAMS:
# None



if [[ "$EUID" != 0 ]]; then
    echo "STARTUP WORKER: Insufficient privilege. Skipping startup."
    exit
fi



# GET GLOBAL VARIABLES
GAMEVER=$(cat /minecraft/cum.conf | grep "^[^#;]" | grep 'GAMEVER=' | cut -d '=' -f 2)







# CLEAR TMP DIRECTORY
rm -rf /minecraft/tmp
mkdir /minecraft/tmp



# GET AND PROCESS AVAILABLE LOAD INFORMATION
echo "(worker) UPDATE: Getting latest build information for $GAMEVER..."

curl -s -X 'GET' "https://api.papermc.io/v2/projects/paper/versions/$GAMEVER/builds" -H 'accept: application/json' -o /minecraft/tmp/builds.json > /dev/null
jq '.builds[-1] | {build, channel, downloads}' /minecraft/tmp/builds.json > /minecraft/tmp/latest.json



# DETERMINE THE LATEST BUILD NUMBER
FOUND=false
I=1

while [ $FOUND = false ];
do
        ((I++))
        # if the channel in latest.json is experimental...
        if [[ $(jq '.channel' /minecraft/tmp/latest.json) = '"experimental"' ]]; then
                # get the second-oldest build version from builds.json and overwrite latest.json with it
                jq ".builds[-$I] | {build, channel, downloads}" /minecraft/tmp/builds.json > /minecraft/tmp/latest.json
        else
                # if the channel in latest.json is NOT experimental, we found the latest stable (default channel) version
                FOUND=true
        fi
done



# STORE INFORMATION ABOUT THE LATEST STABLE VERSION
BUILD=$(jq '.build' /minecraft/tmp/latest.json)
NAME=$(jq '.downloads.application.name' /minecraft/tmp/latest.json | tail -c +2 | head -c -2)
CHECKSUM=$(jq '.downloads.application.sha256' /minecraft/tmp/latest.json | tail -c +2 | head -c -2)



# DOWNLOAD THE LATEST JAR FILE
echo "(worker) UPDATE: Downloading latest stable jar file..."

wget -q https://api.papermc.io/v2/projects/paper/versions/$GAMEVER/builds/$BUILD/downloads/$NAME -P /minecraft/tmp/



# TEST THE CHECKSUM
TESTSUM="$(sha256sum /minecraft/tmp/$NAME | cut -d " " -f 1)"

if [ $TESTSUM != $CHECKSUM ]; then
        echo "UPDATE: Checksum comparison of download failed. This is a security risk. Update failed."
        exit
fi



# MOVE THE JAR TO THE /minecraft/jars/ FOLDER AND MAKE IT EXECUTABLE
echo "(worker) UPDATE: Setting jar file as new global default."

mv /minecraft/tmp/$NAME /minecraft/jars/
chmod +x /minecraft/jars/$NAME



# UPDATE THE LATEST FILE FOR GLOBAL SERVER UPDATES
echo "/minecraft/jars/$NAME" > /minecraft/jars/latest



# CLEAN UP
rm -rf /minecraft/tmp
mkdir /minecraft/tmp



# WE'RE DONE!
echo "(worker) UPDATE: Update complete. Changes won't take effect until a server restart."