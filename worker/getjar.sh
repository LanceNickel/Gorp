#!/usr/bin/env bash

### [JAR DOWNLOAD WORKER] ##########################################
#   Description:  Worker script that performs the update tasks.
#   Parameters:   1: (required) Game version

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

MODE=$2
ARG=$3







####







#### DOWNLOAD BY URL ############

if [[ "$MODE" == "-u" ]]; then

        #### Download the JAR

        echo "Downloading JAR file from URL..."
        cd /tmp/gorp/ || handle_error "Failed to cd to /tmp/gorp."
        wget -q $ARG || handle_error "Failed to download passed URL."



        #### Move to JARS and print file name

        FILENAME="$(echo $ARG | grep -o $(ls))"
        cp ./$FILENAME $HOMEDIR/jars/ || handle_error "Failed to copy downloaded file to jars directory."
        echo -e "JAR file downloaded!\nPath: $HOMEDIR/jars/$FILENAME"
         
fi







#### DOWNLOAD BY GAME VERSION ############

if [[ "$MODE" == "-g" ]]; then

        # If ARG is set to 'latest', get the latest available stable paper version and build
        if [[ "$ARG" == 'latest' ]]; then
                VERSIONS=$(curl -s -H "User-Agent: $USER_AGENT" https://fill.papermc.io/v3/projects/paper/versions | jq -r '.versions[].version.id')

                ITERS=0

                for version in ${VERSIONS}; do

                        # Get latest stable build for version
                        LATEST_BUILD=$(curl -s -H "User-Agent: $USER_AGENT" https://fill.papermc.io/v3/projects/paper/versions/${version}/builds | jq -r 'map(select(.channel == "STABLE")) | .[0] | .id')

                        if [ "$LATEST_BUILD" != "null" ]; then
                                ARG="$version"
                                break
                        fi

                        ITERS=$(($ITERS+1))

                        if [[ $ITERS -ge 10 ]]; then
                                handle_error "Not able to find latest game version."
                        fi

                done
        fi

        # Get latest stable build
        LATEST_BUILD=$(curl -s -H "User-Agent: $USER_AGENT" https://fill.papermc.io/v3/projects/paper/versions/${ARG}/builds | jq -r 'map(select(.channel == "STABLE")) | .[0] | .id' 2>/dev/null)

        if [[ "$?" != "0" ]]; then
                handle_error "Build for game version $ARG not found."
        fi

        if [ "$LATEST_BUILD" != "null" ]; then
                BUILD="$LATEST_BUILD"
        else
                handle_error "A stable build was not found for game version $ARG. Gorp cannot install experimental builds, download them manually."
        fi








        ####







        #### DOWNLOAD THE FILE AND VERIFY IT ############

        #### Get build info

        BUILD_INFO=$(curl -s -H "User-Agent: $USER_AGENT" https://fill.papermc.io/v3/projects/paper/versions/$ARG/builds/$BUILD)
        URL=$(echo "$BUILD_INFO" | jq -r .downloads[].url)
        CHECKSUM=$(echo "$BUILD_INFO" | jq -r .downloads[].checksums.sha256)
        FILENAME="paper-${ARG}-${BUILD}.jar"







        #### DOWNLOAD THE BUILD ############

        echo "Downloading latest stable build for game version $ARG..."
        curl --silent --output /tmp/gorp/"$FILENAME" "$URL" || handle_error "Failed to download JAR file."



        #### Test checksum

        TESTSUM="$(sha256sum /tmp/gorp/$FILENAME | cut -d " " -f 1)"

        if [[ "$TESTSUM" != "$CHECKSUM" ]]; then
                handle_error "Downloaded JAR file failed checksum test."
        fi







        #### INSTALL ############

        #### Move JAR to jars

        echo "Installing version $ARG build $BUILD..."
        mv /tmp/gorp/"$FILENAME" "$HOMEDIR"/jars/ || handle_error "Failed to move JAR to jars folder."



        #### Done!
        
        echo -e "JAR file downloaded!\nPath: $HOMEDIR/jars/$FILENAME"

fi
