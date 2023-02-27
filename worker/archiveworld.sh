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

if [[ "$1" != "pleasedontdothis" ]]; then
    echo "archiveworld.sh: Not intended to be run directly. Exit (13)."
    exit 13
fi



#### SCRIPT PARAMETERS ################

SERVER=$2
WORLD_TO_ARCHIVE=$3

OPTIONS=$(ls $HOMEDIR/servers/$SERVER/ | grep '_nether' | cut -d '-' -f2 | cut -d '_' -f1)



####



# IF WORLD_TO_ARCHIVE NOT SPECIFIED, ASK USER

if [ "$WORLD_TO_ARCHIVE" == "" ]; then
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



# CREATE TMP DIRECTORY

rm -rf $HOMEDIR/tmp
mkdir -p $HOMEDIR/tmp/$WORLD_TO_ARCHIVE



# COMPRESS THE WORLD FILES

echo "archiveworld.sh: Archiving $WORLD_TO_ARCHIVE..."

cp -r $HOMEDIR/servers/$SERVER/world-$WORLD_TO_ARCHIVE/ $HOMEDIR/tmp/$WORLD_TO_ARCHIVE/
cp -r $HOMEDIR/servers/$SERVER/world-${WORLD_TO_ARCHIVE}_nether/ $HOMEDIR/tmp/$WORLD_TO_ARCHIVE/
cp -r $HOMEDIR/servers/$SERVER/world-${WORLD_TO_ARCHIVE}_the_end/ $HOMEDIR/tmp/$WORLD_TO_ARCHIVE/

cd $HOMEDIR/tmp
tar -czf $WORLD_TO_ARCHIVE.tar.gz $WORLD_TO_ARCHIVE >/dev/null 2>/dev/null



# MAKE SURE ARCHIVE DESTINATION EXISTS

mkdir -p $ARCHIVE_DEST/$SERVER



# COPY THE WORLD FILES TO DESTINATION

echo "archiveworld.sh: Moving world to archive destination... ($ARCHIVE_DEST/$WORLD_TO_ARCHIVE.tar.gz)"

cp $HOMEDIR/tmp/$WORLD_TO_ARCHIVE.tar.gz $ARCHIVE_DEST/$SERVER/



# ARCHIVE INTEGRITY GUARD

CHECKSUM=$(md5sum $HOMEDIR/tmp/$WORLD_TO_ARCHIVE.tar.gz | cut -d ' ' -f1)
TESTSUM=$(md5sum $ARCHIVE_DEST/$SERVER/$WORLD_TO_ARCHIVE.tar.gz | cut -d ' ' -f1)

if [ "$CHECKSUM" != "$TESTSUM" ]; then
    echo "archiveworld.sh: Checksum failed. Ensure the archive destination directory is correctly configured. Exiting."
    exit
fi



# CLEAN UP

rm -rf $HOMEDIR/servers/$SERVER/world-$WORLD_TO_ARCHIVE
rm -rf $HOMEDIR/servers/$SERVER/world-${WORLD_TO_ARCHIVE}_nether
rm -rf $HOMEDIR/servers/$SERVER/world-${WORLD_TO_ARCHIVE}_the_end

rm -rf $HOMEDIR/tmp



echo "archiveworld.sh: World archived."