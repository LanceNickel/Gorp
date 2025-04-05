#!/usr/bin/env bash

### [CREATE WORKER] ###############################################
#   Description:  Worker script that performs the new server tasks.
#   Parameters:   1: (required) Server directory name
#   Parameters:   2: (required) World name

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
WORLD=$3
VELOCITY=$4







####






#### CREATE SERVER DIRECTORY AND COPY RUN.SH ############

mkdir $HOMEDIR/servers/$SERVER || handle_error "Failed to create server directory."
cp /usr/local/bin/gorpmc/run.sh $HOMEDIR/servers/$SERVER/ || handle_error "Failed to copy run.sh file to new server directory."







#### PREPARE SERVER FILES ############

echo "eula=true" > $HOMEDIR/servers/$SERVER/eula.txt || handle_error "Failed to echo eula accept to eula.txt."
echo "level-name=world-$WORLD" > $HOMEDIR/servers/$SERVER/server.properties || handle_error "Failed to echo to server.properties."







#### VELOCITY SETUP (if called for) ############

if [[ "$VELOCITY" == "true" ]]; then

    #### Get Velocity forwarding secret

    read -r -p "Velocity forwarding secret: " secret
    sleep 1
    echo -e "\nPerforming setup for Velocity. This will take a few moments..."

    ### Turn online-mode off in server.properties

    echo "online-mode=false" >> $HOMEDIR/servers/$SERVER/server.properties || handle_error "Failed to echo to server.properties."



    #### Start and stop the server to generate Paper properties files

    bash /usr/local/bin/gorpmc/worker/start.sh $1 $SERVER -y > /dev/null || handle_error "Failed to start server."
    sleep 3
    bash /usr/local/bin/gorpmc/worker/shutdown.sh $1 $SERVER now > /dev/null || handle_error "Failed to stop server."
    sleep 1



    #### Update Paper config for Velocity

    yq -iy '.proxies.velocity.enabled = true' $HOMEDIR/servers/$SERVER/config/paper-global.yml 2> /dev/null || yq -i '.proxies.velocity.enabled = true' $HOMEDIR/servers/$SERVER/config/paper-global.yml 2> /dev/null || handle_error "Failed to enable Velocity in paper-global settings."
    yq -iy '.proxies.velocity."online-mode" = true' $HOMEDIR/servers/$SERVER/config/paper-global.yml 2> /dev/null || yq -i '.proxies.velocity."online-mode" = true' $HOMEDIR/servers/$SERVER/config/paper-global.yml 2> /dev/null || handle_error "Failed to enable Velocity online mode in paper-global settings."
    secret="$secret" yq -iy '.proxies.velocity.secret = env(secret)' $HOMEDIR/servers/$SERVER/config/paper-global.yml 2> /dev/null || secret="$secret" yq -i '.proxies.velocity.secret = env(secret)' $HOMEDIR/servers/$SERVER/config/paper-global.yml 2> /dev/null || handle_error "Failed to set Velocity forwarding secret in paper-global settings."

fi









#### WE MADE IT ############

echo "Server created!"

if [[ "$VELOCITY" == "true" ]]; then
    echo "Velocity has been configured for server-side setup with Modern forwarding. Configure your Velocity proxy settings if needed."
fi
