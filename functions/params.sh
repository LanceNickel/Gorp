#!/usr/bin/env bash

### [PARAMETERS] ##################################################
#   Description: Scripts/callable functions to handle params.

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################

# Copyright (C) Lance Nickel 2023.
# Distributed under GNU GPL v3.
# <https://gorp.lanickel.com/license/>







######## CONFIG FILE GUARD

if [[ ! -f "/usr/local/etc/gorp.conf" ]]; then
    handle_error "Configuration file not found."
fi







######## GET CONFIG FILE ITEMS

GAMEVER=$(cat /usr/local/etc/gorp.conf | grep "^[^#;]" | grep 'GAMEVER=' | cut -d '=' -f2)
RAM=$(cat /usr/local/etc/gorp.conf | grep "^[^#;]" | grep -e '^RAM=' | cut -d '=' -f2)
MAX_RAM=$(cat /usr/local/etc/gorp.conf | grep "^[^#;]" | grep 'MAX_RAM=' | cut -d '=' -f2)
HOMEDIR=$(cat /usr/local/etc/gorp.conf | grep "^[^#;]" | grep 'HOMEDIR=' | cut -d '=' -f2)
BACKUP_DEST=$(cat /usr/local/etc/gorp.conf | grep "^[^#;]" | grep 'BACKUP_DEST=' | cut -d '=' -f2)
ARCHIVE_DEST=$(cat /usr/local/etc/gorp.conf | grep "^[^#;]" | grep 'ARCHIVE_DEST=' | cut -d '=' -f2)
LATEST_JAR=$(cat $HOMEDIR/jars/latest)







######## MAKE SURE ALL ARE POPULATED

if [[ "$GAMEVER" == "" ]] || [[ "$RAM" == "" ]] || [[ "$HOMEDIR" == "" ]] || [[ "$BACKUP_DEST" == "" ]] || [[ "$ARCHIVE_DEST" == "" ]] || [[ "$LATEST_JAR" == "" ]]; then
    handle_error "One or more required options in gorp.conf not set."
fi