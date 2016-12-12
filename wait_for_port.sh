#!/bin/bash

#http://stackoverflow.com/questions/11968971/how-to-check-if-sshd-runs-on-a-remote-machine

if [ $# -ne 2 ]; then
    errexit 'Usage: wait_for_port.sh IP PORT'
fi

nc -z $1 $2
while test $? -gt 0
do
        sleep 5 
        echo "Waiting for port "$2"..."
        nc -z $1 $2
done