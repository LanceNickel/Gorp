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
# Default:         JAR=$(cat /minecraft/jars/latest)

JAR=$(cat /minecraft/jars/latest)



######## Option: RAM #############################################################
# Description:     An (optional) custom RAM allocation for this server.
# Expected value:  Amount of RAM as an integer, followed immedately by "G" (ex: 4G)
# Default:         RAM=$(cat /minecraft/gorp.conf | grep "^[^#;]" | grep 'RAM=' | cut -d '=' -f 2)

RAM=$(cat /minecraft/gorp.conf | grep "^[^#;]" | grep 'RAM=' | cut -d '=' -f 2)



#### END OF OPTIONS! Please do not edit below this line.



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
