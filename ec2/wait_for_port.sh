#!/bin/bash

#http://stackoverflow.com/questions/11968971/how-to-check-if-sshd-runs-on-a-remote-machine

if [ $# -ne 2 ]; then
    errexit 'Usage: wait_for_port.sh IP PORT'
fi
nc -z -w 2 $1 $2
while test $? -ne 0
do
        echo "Waiting for port "$2"..."
        sleep 5
        nc -z -w 2 $1 $2
done
