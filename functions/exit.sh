#!/usr/bin/env bash

### [GORP EXIT FUNCTION] ##########################################
#   Description:  Single-function file to exit cleanly on error.

############################ [WARNING] ############################
##    No part of this script is designed to be user-editable.    ##
##   This script is OVERWRITTEN any time a Gorp update is run.   ##
###################################################################

# Copyright (C) Lance Nickel 2023.
# Distributed under GNU GPL v3.
# <https://gorp.lanickel.com/license/>



handle_error() {
    message=$1

    if [[ -d "/tmp/gorp/" ]]; then
        rm -rf /tmp/gorp/
    fi

    if [[ "$message" == "" ]]; then
        message="Gorp encoutered a problem and needed to exit."
    fi

    echo "ERROR: $message"

    exit 1
}