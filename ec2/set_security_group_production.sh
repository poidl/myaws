#!/bin/bash


errexit() {
    echo "*MYERROR* in $(basename $0): "$1 1>&2
    exit 1
}

[ ! -z $MYAWS_SECURITY_GROUP_ID ] || errexit "MYAWS_SECURITY_GROUP_ID not set"

sg_groupid=$MYAWS_SECURITY_GROUP_ID
MYIP=$(wget http://ipinfo.io/ip -qO -)

sg_ingress() {
    ssh_cidr=$(aws ec2 describe-security-groups \
        --group-ids "$sg_groupid" \
        --query "SecurityGroups[*].IpPermissions[?FromPort==\`22\`].IpRanges" \
        --output text) || errexit "Can't find SSH ingress ip addresses"
    for i in $ssh_cidr; do
        echo "Revoking SSH ingress from $i"
        aws ec2 revoke-security-group-ingress --group-id "$sg_groupid" --protocol tcp --port 22 --cidr "$i"
    done
    echo "Allowing SSH ingress from $MYIP/32"
    aws ec2 authorize-security-group-ingress --group-id "$sg_groupid" --protocol tcp --port 22 --cidr "$MYIP/32"
}

if [ $# -ne 0 ]; then
    errexit 'Usage: set_security_group_production.sh'
fi

sg_ingress
