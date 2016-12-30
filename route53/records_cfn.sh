#!/bin/bash

errexit() {
    echo "*MYERROR* in $(basename $0): "$1 1>&2
    exit 1
}

[ ! -z $MYAWS_ROUTE53_TEMPLATE_TOALIAS ] || errexit "MYAWS_ROUTE53_TEMPLATE_TOALIAS not set"
[ ! -z $MYAWS_HOSTEDZONE_DN ] || errexit "MYAWS_HOSTEDZONE_DN not set"


setjson() {
    local TEMPLATE=$MYAWS_ROUTE53_TEMPLATE_TOALIAS
    local TEMPLATEFILE=${TEMPLATE#file://}
    local DN=$(aws cloudfront list-distributions --query "DistributionList.Items[?Aliases.Items[0]=="MYAWS_HOSTEDZONE_DN"].DomainName" --output text) || errexit "Could not find domain name of cloudfront distribution"
    local jf=$TEMPLATEFILE
    cp $jf $jf"_backup"
    jq --arg ARG1 "$DN" '.Changes[].ResourceRecordSet.AliasTarget.DNSName=$ARG1' $jf > tmp.$$.json && mv tmp.$$.json $jf
}

change_records() {
    local zoneid=$(aws route53 list-hosted-zones-by-name \
        --dns-name "$MYAWS_HOSTEDZONE_DN" \
        --query "HostedZones[?DNSName=="$MYAWS_HOSTEDZONE_DN"].Id" \
        --output text)
    aws route53 change-resource-record-sets \
        --hosted-zone-id "$zoneid" \
        --change-batch $MYAWS_ROUTE53_TEMPLATE_TOALIAS
}

setjson
change_records
