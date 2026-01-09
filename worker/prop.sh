#!/usr/bin/env bash

### [PROP WORKER] #################################################
#   Description:  Worker script that performs the world reset.
#   Parameters:   1: (required) Server directory name
#                 2: (optional) World (level) name for directory

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################

# Copyright (C) Lance Nickel 2026.
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

SERVER="$2"
KEY="$3"
VALUE="$4"







####







#### OPEN server.properties IN PREFERRED TEXT EDITOR IF K/V NOT PASSED

if [[ "$KEY" == "" ]] && [[ "$VALUE" == "" ]]; then

    #### Prompt for text editor if invalid/unset

    if [[ "$TEXT_EDITOR" != "vim" ]] && [[ "$TEXT_EDITOR" != "vi" ]] && [[ "$TEXT_EDITOR" != "emacs" ]] && [[ "$TEXT_EDITOR" != "nano" ]]; then
        echo "Please choose a text editor. (Ensure it's installed, too!)"

        select editor in vi vim emacs nano
        do
            TEXT_EDITOR=$editor
            break
        done

        sudo sed -i "90s:.*:TEXT_EDITOR=$editor:" /usr/local/etc/gorp.conf || handle_error "Failed to update TEXT_EDITOR in config"

    fi


    #### Open server.properties in preferred text editor

    "$TEXT_EDITOR" "$HOMEDIR"/servers/"$SERVER"/server.properties || handle_error "Failed to open server.properties using $TEXT_EDITOR"

fi







#### UPDATE SERVER PROPERTIES IF K/V PASSED ############

current="$(grep -e "^$KEY=" $HOMEDIR/servers/$SERVER/server.properties | cut -d '=' -f2)"
sed -i -e "s/$KEY=$current/$KEY=$VALUE/g" $HOMEDIR/servers/$SERVER/server.properties || handle_error "Failed to update server.properties."







#### WE MADE IT ############

if [[ "$KEY" != "" ]]; then
    echo "Server properties updated! Old value was: '$current'."
    echo "A server restart may be required for changes to take effect."
else
    echo "Server properties updated! A server restart may be required for changes to take effect."
fi
