#!/bin/bash

DESCRIPTION="Security group for testing of home page"

errexit() {
    echo "*MYERROR* in $(basename $0): "$1 1>&2
    exit 1
}

[ ! -z $MYAWS_SG_NAME_TESTING ] || errexit "MYAWS_SG_NAME_TESTING not set"

aws ec2 create-security-group --group-name $MYAWS_SG_NAME_TESTING --description "$DESCRIPTION"
GROUPID=$(aws ec2 describe-security-groups --group-names $MYAWS_SG_NAME_TESTING --query "SecurityGroups[*].GroupId" --output text)

# SSH
MYIP=$(wget http://ipinfo.io/ip -qO -)
aws ec2 authorize-security-group-ingress --group-id $GROUPID --protocol tcp --port 22 --cidr "$MYIP/32"

# HTTP
aws ec2 authorize-security-group-ingress --group-id $GROUPID --protocol tcp --port 80 --cidr "$MYIP/32"

# HTTPS
aws ec2 authorize-security-group-ingress --group-id $GROUPID --protocol tcp --port 443 --cidr "$MYIP/32"

