#!/usr/bin/env bash

### [CONFIG WORKER] ###############################################
#   Description:  Worker script that opens txt and reloads crontab.
#   Parameters:   1: (optional) Server directory name

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

SERVER="$2"







####







#### PROMPT FOR TEXT EDITOR IF INVALID ############

if [[ "$TEXT_EDITOR" != "vim" ]] && [[ "$TEXT_EDITOR" != "vi" ]] && [[ "$TEXT_EDITOR" != "emacs" ]] && [[ "$TEXT_EDITOR" != "nano" ]]; then
    echo "Please choose a text editor. (Ensure it's installed, too!)"

    select editor in vi vim emacs nano
    do
        TEXT_EDITOR=$editor
        break
    done

    sudo sed -i "90s:.*:TEXT_EDITOR=$editor:" /usr/local/etc/gorp.conf || handle_error "Failed to update TEXT_EDITOR in config"

fi







#### DETERMINE WHICH CONFIG FILE TO OPEN ############

#### A server was specified

if [[ "$SERVER" != "" ]]; then
    if [[ -f "$HOMEDIR/servers/$SERVER/run.sh" ]]; then
        sudo "$TEXT_EDITOR" "$HOMEDIR/servers/$SERVER/run.sh" || handle_error "Failed to open $HOMEDIR/gorpmc/servers/$SERVER/run.sh using $TEXT_EDITOR"
    else
        handle_error "Server config file not found."
    fi



#### No server was specified

else
    sudo "$TEXT_EDITOR" "/usr/local/etc/gorp.conf" || handle_error "Failed to open /usr/local/etc/gorp.conf using $TEXT_EDITOR"

fi










#### GET NEW CONFIG OPTIONS ############

## Refresh params
. /usr/local/bin/gorpmc/functions/params.sh







#### HANDLE CRONTAB ############

## Get the current crontab and store in tmp
crontab -l > /tmp/gorp/crontab

## Grep line
line="$(cat /tmp/gorp/crontab | grep -n 'bash /usr/local/bin/gorp update-jar __DO_NOT_CHANGE_THIS__' | cut -d ':' -f1)"

## Is line present?
if [[ "$line" != "" ]]; then
    present="yes"
else
    present="no"
fi



#### If automatic updates are enabled...

if [[ "$UPDATE_FREQUENCY" != "disabled" ]]; then

    ## If line is present, sed it
    if [[ "$present" == "yes" ]]; then

        ## Edit the line and install the new crontab
        sed -i "${line}s:.*:$UPDATE_FREQUENCY    bash /usr/local/bin/gorp update-jar __DO_NOT_CHANGE_THIS__:" /tmp/gorp/crontab || handle_error "Failed to update tmp crontab file"
        crontab /tmp/gorp/crontab || handle_error "Failed to install new crontab"

    fi


    ## If line not there, append
    if [[ "$present" == "no" ]]; then

        ## Append the line and install the new crontab
        echo "$UPDATE_FREQUENCY    bash /usr/local/bin/gorp update-jar __DO_NOT_CHANGE_THIS__" >> /tmp/gorp/crontab
        crontab /tmp/gorp/crontab || handle_error "Failed to install new crontab"

    fi

fi



#### If automatic updates are disabled...

if [[ "$UPDATE_FREQUENCY" == "disabled" ]]; then

    ## If line is present, remove it (if not, it's already gone... nothing to do!)
    if [[ "$present" == "yes" ]]; then
        sed -i -e "${line}d" /tmp/gorp/crontab || handle_error "Failed to update tmp crontab file"
        crontab /tmp/gorp/crontab || handle_error "Failed to install new crontab"
    fi

fi





    







#### WE MADE IT ############

echo "Configuration updated!"