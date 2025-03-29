#!/usr/bin/env bash

### [ARCHIVE-WORLD WORKER] ########################################
#   Description:  Worker script that performs the world archival.
#   Parameters:   1: (required) Server directory name
#                 2: (optional) World (level) name for directory

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################

# Copyright (C) Lance Nickel 2025.
# Distributed under GNU GPL v3.
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

SERVER=$2
WORLD_TO_ARCHIVE=$3

OPTIONS=$(list_worlds "$SERVER")







####







#### IF WORLD_TO_ARCHIVE NOT SPECIFIED, ASK USER ############

if [[ "$WORLD_TO_ARCHIVE" == "" ]]; then
    while [ true ]
    do
        echo -e "Options:\n$OPTIONS"

        read -r -p "Please enter a world to archive: " response

        TEST=$(echo $OPTIONS | grep -w $response)

        if [[ "$TEST" != "" ]]; then
            WORLD_TO_ARCHIVE=$response
            break
        else
            echo -e "\nSpecified world does not exist.\n"
        fi
    done
fi







#### HANDLE WORLD FILES ############

#### Create destination

mkdir -p $ARCHIVE_DEST/$SERVER || handle_error "Failed to make destination folder"



#### Copy files to tmp

echo "Copying files for $WORLD_TO_ARCHIVE..."
cp -r $HOMEDIR/servers/$SERVER/world-$WORLD_TO_ARCHIVE/ /tmp/gorp/$WORLD_TO_ARCHIVE/ || handle_error "Failed to cp overworld files to tmp."
cp -r $HOMEDIR/servers/$SERVER/world-${WORLD_TO_ARCHIVE}_nether/ /tmp/gorp/$WORLD_TO_ARCHIVE/ || handle_error "Failed to cp nether files to tmp."
cp -r $HOMEDIR/servers/$SERVER/world-${WORLD_TO_ARCHIVE}_the_end/ /tmp/gorp/$WORLD_TO_ARCHIVE/ || handle_error "Failed to cp end files to tmp."



#### Tarball files in tmp

echo "Compressing files..."
cd /tmp/gorp || handle_error "Failed to cd to /tmp/gorp/."
tar -czf $WORLD_TO_ARCHIVE.tar.gz $WORLD_TO_ARCHIVE >/dev/null 2>/dev/null || handle_error "Failed to compress archive files."



#### Copy tarball to destination

echo "Moving archive to destination..."
cp /tmp/gorp/$WORLD_TO_ARCHIVE.tar.gz $ARCHIVE_DEST/$SERVER/ || handle_error "Failed to copy archive to destination."



#### Make sure the files made it via checksum

CHECKSUM=$(sha256sum /tmp/gorp/$WORLD_TO_ARCHIVE.tar.gz | cut -d ' ' -f1)
TESTSUM=$(sha256sum $ARCHIVE_DEST/$SERVER/$WORLD_TO_ARCHIVE.tar.gz | cut -d ' ' -f1)

if [[ "$CHECKSUM" != "$TESTSUM" ]]; then
    handle_error "Archived files in destination failed checksum test."
fi







#### WE MADE IT ############

echo "World archived!"