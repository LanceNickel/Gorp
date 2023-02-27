#!/usr/bin/env bash

### [RUN SERVER IN-DIRECTORY WORKER] ##############################
#   Description:  Worker that actually executes a server JAR.
#   Parameters:   None
#   Global Conf:  JAR, RAM

############################ [WARNING] ############################
##   Small portions of this script are designed to be changed.   ##
##     All other parts are OVERWRITTEN during a Gorp update.     ##
###################################################################



######## Option: JAR #############################################################
# Description:     An (optional) custom JAR file to run as the server.
# Expected value:  Absolute path to a JAR file
# Default:         JAR=$(cat $HOMEDIR/jars/latest)

JAR=$(cat $HOMEDIR/jars/latest)



######## Option: RAM #############################################################
# Description:     An (optional) custom RAM allocation for this server.
# Expected value:  Amount of RAM as an integer, followed immedately by "G" (ex: 4G)
# Default:         RAM=$(cat $HOMEDIR/gorp.conf | grep "^[^#;]" | grep 'RAM=' | cut -d '=' -f 2)

RAM=$(cat $HOMEDIR/gorp.conf | grep "^[^#;]" | grep 'RAM=' | cut -d '=' -f 2)



#### END OF OPTIONS! Please do not edit below this line.



# KEY GUARD (to ensure a good, clean startup)

if [ "$1" != "bjcisBOOMIN" ]; then
        echo "run.sh: Incorrect key. This script is not meant to be directly executed by the user. Exiting."
        exit
fi



####



# EXECUTE SERVER, WAIT FOR PROCESS TO DIE

while [ true ]; do
        java -Xmx$RAM -Xms$RAM -jar $JAR nogui

        echo -e "\n\nTHIS SERVER HAS STOPPED! Press any key to prevent restart."

        read -t 5 input;

        if [ $? == 0 ]; then
                break;
        else
                echo "Restarting server..."
        fi
done
