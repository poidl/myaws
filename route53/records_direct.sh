#!/bin/bash

errexit() {
    echo "*MYERROR* in $(basename $0): "$1 1>&2
    exit 1
}

! -z $MYAWS_ROUTE53_TEMPLATE_TOA ] || errexit "MYAWS_ROUTE53_TEMPLATE_TOA not set"
[ ! -z $MYAWS_HOSTEDZONE_DN ] || errexit "MYAWS_HOSTEDZONE_DN not set"


if [ $# -ne 1 ]; then
    errexit 'Usage: records_direct.sh IP'
fi 

setjson() {
    local TEMPLATE=$MYAWS_ROUTE53_TEMPLATE_TOA
    local TEMPLATEFILE=${TEMPLATE#file://}
    if [ $# -ne 1 ]; then
        errexit 'Usage: setjson IP'
    fi 
    local jf=$TEMPLATEFILE
    cp $jf $jf"_backup"
    # TODO: don't hardcode index in next line
    jq --arg ARG1 "$1" '.Changes[].ResourceRecordSet.ResourceRecords[0].Value=$ARG1' $jf > tmp.$$.json && mv tmp.$$.json $jf
}

change_records() {
    local zoneid=$(aws route53 list-hosted-zones-by-name \
        --dns-name "$MYAWS_HOSTEDZONE_DN" \
        --query "HostedZones[?DNSName=="$MYAWS_HOSTEDZONE_DN"].Id" \
        --output text)
    aws route53 change-resource-record-sets \
        --hosted-zone-id "$zoneid" \
        --change-batch $MYAWS_ROUTE53_TEMPLATE_TOA
}

ssh -t "ec2-user@$1" "bash -s" < scripts_remote/setjson.sh -- "~/proxy/conf.json $MYAWS_HOSTEDZONE_DN" || errexit "Setting hostname failed"
ssh -t "ec2-user@$1" < scripts_remote/serverstart.sh || errexit "Couldn't start servers'"
setjson $1
change_records
