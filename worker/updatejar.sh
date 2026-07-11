#!/usr/bin/env bash

### [JAR UPDATE WORKER] ############################################
#   Description:  Worker script that performs the jar update tasks.
#   Parameters:   1: (required) Server directory name
#   Global Conf:  GAMEVER

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################

# Copyright (C) Lance Nickel 2026.
# Gorp is distributed under the MIT license.
# <https://gorp.lanickel.com/license/>



#### SETUP ############

#### Globals

. /usr/local/bin/gorpmc/functions/exit.sh
. /usr/local/bin/gorpmc/functions/params.sh
. /usr/local/bin/gorpmc/functions/functions.sh



#### Key guard

if [[ "$1" != "pleasedontdothis" ]]; then
    handle_error "Script not meant to be run directly."
fi



#### Collect arguments & additional variables

# If GAMEVER is set to 'latest', get the latest available stable paper version and build
if [[ "$GAMEVER" == 'latest' ]]; then
    VERSIONS=$(curl -s -H "User-Agent: $USER_AGENT" https://fill.papermc.io/v3/projects/paper/versions | jq -r '.versions[].version.id')

    ITERS=0

    for version in ${VERSIONS}; do

        # Get latest stable build for version
        LATEST_BUILD=$(curl -s -H "User-Agent: $USER_AGENT" https://fill.papermc.io/v3/projects/paper/versions/${version}/builds | jq -r 'map(select(.channel == "STABLE")) | .[0] | .id')

        if [ "$LATEST_BUILD" != "null" ]; then
            GAMEVER="$version"
            break
        fi

        ITERS=$(($ITERS+1))

        if [[ $ITERS -ge 10 ]]; then
            handle_error "Not able to find latest game version."
        fi

    done
fi

# Get latest stable build
LATEST_BUILD=$(curl -s -H "User-Agent: $USER_AGENT" https://fill.papermc.io/v3/projects/paper/versions/${GAMEVER}/builds | jq -r 'map(select(.channel == "STABLE")) | .[0] | .id' 2>/dev/null)

if [[ "$?" != "0" ]]; then
    handle_error "Build for game version $GAMEVER not found."
fi

if [ "$LATEST_BUILD" != "null" ]; then
    BUILD="$LATEST_BUILD"
else
    handle_error "A stable build was not found for game version $GAMEVER. Gorp cannot install experimental builds, download them manually."
fi








####







#### GET INST. VERSION && PARSE LATEST BUILD INFO ############

#### Installed version

INSTALLED=$(cat $HOMEDIR/jars/latest)



#### Get build info

BUILD_INFO=$(curl -s -H "User-Agent: $USER_AGENT" https://fill.papermc.io/v3/projects/paper/versions/$GAMEVER/builds/$BUILD)
URL=$(echo "$BUILD_INFO" | jq -r .downloads[].url)
CHECKSUM=$(echo "$BUILD_INFO" | jq -r .downloads[].checksums.sha256)
FILENAME="paper-${GAMEVER}-${BUILD}.jar"







#### DOWNLOAD THE BUILD ############

echo "Downloading latest stable build for game version $GAMEVER..."
curl --silent --output /tmp/gorp/"$FILENAME" "$URL" || handle_error "Failed to download JAR file."



#### Test checksum

TESTSUM="$(sha256sum /tmp/gorp/$FILENAME | cut -d " " -f 1)"

if [[ "$TESTSUM" != "$CHECKSUM" ]]; then
    handle_error "Downloaded JAR file failed checksum test."
fi







#### INSTALL ############

#### Move JAR to jars

echo "Installing version $GAMEVER build $BUILD..."
mv /tmp/gorp/"$FILENAME" "$HOMEDIR"/jars/ || handle_error "Failed to move JAR to jars folder."



#### Update latest jar file

echo "$HOMEDIR/jars/$FILENAME" > $HOMEDIR/jars/latest || handle_error "Failed to update latest JAR file."







#### WE MADE IT ############

echo "JAR updated! Changes won't take effect until a server restart."
