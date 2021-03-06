#!/bin/bash

# Adapted from J. Saryerwinnie's talk https://www.youtube.com/watch?v=TnfqJYPjD9I

errexit() {
    echo "*MYERROR* in $(basename $0): "$1 1>&2
    exit 1
}

[ ! -z $AWS_DEFAULT_REGION ] || errexit "AWS_DEFAULT_REGION not set"
[ ! -z $MYAWS_INSTANCE_TYPE ] || errexit "MYAWS_INSTANCE_TYPE not set"
[ ! -z $MYAWS_KEY_NAME ] || errexit "MYAWS_KEY_NAME not set"
[ ! -z $MYAWS_SECURITY_GROUP_ID ] || errexit "MYAWS_SECURITY_GROUP_ID not set"

launch_instance() {
    local instancetype=$MYAWS_INSTANCE_TYPE
    local keyname=$MYAWS_KEY_NAME
    local secgroupid=$MYAWS_SECURITY_GROUP_ID
    local region=${AWS_DEFAULT_REGION:-$(aws configure get region)}


    if [ $# -ne 0 ]; then
        errexit 'Usage: ec2_launch.sh'
    fi

    # Get latest ami
    ami="$(list_amis.sh -r $region| head -n 1| cut -f 2)" || errexit "Can't retrieve latest ami"

    instance_id=$(aws ec2 run-instances \
        --image-id "$ami" \
        --count 1 \
        --instance-type "$instancetype" \
        --key-name "$keyname" \
        --security-group-ids "$secgroupid" \
        --output text \
        --query "Instances[0].InstanceId") || errexit "Could not launch instance"

    # TODO: This tag is not useful? "Launch time" is an instance property anyways
    local date=`date -Iseconds`

    aws ec2 create-tags \
        --resources "$instance_id" \
        --tags Key=deploydate,Value="$date" || errexit "Couldn't create tags"
}

launch_instance
echo $instance_id