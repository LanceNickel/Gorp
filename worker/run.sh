#!/usr/bin/env bash
source /usr/local/bin/gorpmc/worker/i_getconfigparams.sh
### [RUN SERVER IN-DIRECTORY WORKER] ##############################
#   Description:  Worker that actually executes a server JAR.
#   Parameters:   None
#   Global Conf:  JAR, RAM

############################ [WARNING] ############################
##   Small portions of this script are designed to be changed.   ##
##     All other parts are OVERWRITTEN during a Gorp update.     ##
###################################################################

# Copyright (C) Lance Nickel 2023.
# Distributed under GNU GPL v3.
# <https://gorp.lanickel.com/license/>




######## Option: CUSTOM_JAR #########################################################
# Description:     An (optional) custom JAR file to run as the server.
# Expected value:  Absolute path to a JAR file
# Default:         CUSTOM_JAR=$LATEST_JAR

CUSTOM_JAR=$LATEST_JAR



######## Option: CUSTOM_RAM #########################################################
# Description:     An (optional) custom RAM allocation for this server.
# Expected value:  Amount of RAM as an integer, followed immedately by "G" (ex: 4G)
# Default:         CUSTOM_RAM=$RAM

CUSTOM_RAM=$RAM







#### END OF OPTIONS! Please do not edit below this line.







### KEY GUARD (to ensure a good, clean startup)

if [[ "$1" == "pleasedontdothis" ]]; then
    handle_error "Script not meant to be run directly."
fi







####







### EXECUTE SERVER, WAIT FOR PROCESS TO DIE

while [ true ]; do
        java -Xmx$CUSTOM_RAM -Xms$CUSTOM_RAM -jar $CUSTOM_JAR nogui

        echo -e "\n\nTHIS SERVER HAS STOPPED! Press any key to prevent restart."

        read -t 5 input;

        if [ $? == 0 ]; then
                break;
        else
                echo "Restarting server..."
        fi
done
