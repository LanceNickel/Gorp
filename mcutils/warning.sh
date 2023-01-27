#!/usr/bin/env bash

# THIS IS THE IN-GAME SERVER ACTION WARNING SCRIPT
# This is a utility function (ends in .sh), it should not be called directly by the command line user.
# This should not need to be updated outside of updates to functionality of the program itself.

# PARAMS:
# 1: Server directory name -- required!
# 2: Action: <stop, restart, power> -- Required!



if [[ "$EUID" != 0 ]]; then
        echo "(worker) WARNING: Insufficient privilege. Warning failed."
        exit
fi



SERVER=$1
ACTION=$2



echo "(worker) WARNING: Sending $ACTION warning in the chat and waiting 30 seconds..."

if [ $ACTION == "power" ]; then
        screen -S $SERVER -X stuff "say ATTENTION: Due to a power outage, this server must be shut down.\n"
        screen -S $SERVER -X stuff "say ATTENTION: This server will shut down in 30 seconds.\n"
else
        screen -S $SERVER -X stuff "say ATTENTION: This server will $ACTION in 30 seconds.\n"
fi

NOT30=true
I=0

while [ $NOT30 == true ];
do
        sleep 1
        ((I++))
        echo -ne "  $I s\r"

        if [ $I -eq "30" ]; then
                NOT30=false
        fi
done

echo -ne "\n"