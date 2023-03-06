#!/usr/bin/env bash

### [ARCHIVE-WORLD WORKER] ########################################
#   Description:  Worker script that performs the world archival.
#   Parameters:   1: (required) Server directory name
#                 2: (optional) World (level) name for directory

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
    if $ERRORS; then echo "archiveworld.sh: Not intended to be run directly. Exit (13)."; fi
    exit 13
fi







#### SCRIPT PARAMETERS ################

source /usr/local/bin/gorpmc/worker/i_getconfigparams.sh

SERVER=$2
WORLD_TO_ARCHIVE=$3

OPTIONS=$(worldOptions "$SERVER")







####







### IF WORLD_TO_ARCHIVE NOT SPECIFIED, ASK USER

if [[ "$WORLD_TO_ARCHIVE" == "" ]]; then
    while [ true ]
    do
        if $OUTPUT; then echo -e "Options:\n$OPTIONS"; fi

        read -r -p "Please enter a world to archive: " response

        TEST=$(echo $OPTIONS | grep -w $response)

        if [[ "$TEST" != "" ]]; then
            WORLD_TO_ARCHIVE=$response
            break
        else
            if $OUTPUT; then echo -e "\nSpecified world does not exist.\n"; fi
        fi
    done
fi







### CREATE TMP DIRECTORY

rm -rf $HOMEDIR/tmp
mkdir -p $HOMEDIR/tmp/$WORLD_TO_ARCHIVE







### COMPRESS THE WORLD FILES

if $OUTPUT; then echo "Archiving $WORLD_TO_ARCHIVE..."; fi

cp -r $HOMEDIR/servers/$SERVER/world-$WORLD_TO_ARCHIVE/ $HOMEDIR/tmp/$WORLD_TO_ARCHIVE/
cp -r $HOMEDIR/servers/$SERVER/world-${WORLD_TO_ARCHIVE}_nether/ $HOMEDIR/tmp/$WORLD_TO_ARCHIVE/
cp -r $HOMEDIR/servers/$SERVER/world-${WORLD_TO_ARCHIVE}_the_end/ $HOMEDIR/tmp/$WORLD_TO_ARCHIVE/

cd $HOMEDIR/tmp
tar -czf $WORLD_TO_ARCHIVE.tar.gz $WORLD_TO_ARCHIVE >/dev/null 2>/dev/null







### MAKE SURE ARCHIVE DESTINATION EXISTS

mkdir -p $ARCHIVE_DEST/$SERVER







### COPY THE WORLD FILES TO DESTINATION

if $OUTPUT; then echo "Moving world to archive destination... ($ARCHIVE_DEST/$WORLD_TO_ARCHIVE.tar.gz)"; fi

cp $HOMEDIR/tmp/$WORLD_TO_ARCHIVE.tar.gz $ARCHIVE_DEST/$SERVER/







### ARCHIVE INTEGRITY GUARD

CHECKSUM=$(md5sum $HOMEDIR/tmp/$WORLD_TO_ARCHIVE.tar.gz | cut -d ' ' -f1)
TESTSUM=$(md5sum $ARCHIVE_DEST/$SERVER/$WORLD_TO_ARCHIVE.tar.gz | cut -d ' ' -f1)

if [[ "$CHECKSUM" != "$TESTSUM" ]]; then
    if $ERRORS; then echo "archiveworld.sh: Archived files in destination failed checksum test. Exit (61)."; fi
    exit 61
fi







### CLEAN UP

rm -rf $HOMEDIR/servers/$SERVER/world-$WORLD_TO_ARCHIVE
rm -rf $HOMEDIR/servers/$SERVER/world-${WORLD_TO_ARCHIVE}_nether
rm -rf $HOMEDIR/servers/$SERVER/world-${WORLD_TO_ARCHIVE}_the_end

rm -rf $HOMEDIR/tmp







if $OUTPUT; then echo "World archived!"; fi