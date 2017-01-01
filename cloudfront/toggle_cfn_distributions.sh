#!/bin/bash

errexit() {
    echo "*MYERROR* in $(basename $0): "$1 1>&2
    exit 1
}

[ ! -z $MYAWS_CFNSTACKNAME ] || errexit "MYAWS_CFNSTACKNAME not set"

if [ $# -ne 1 ]; then
    errexit 'Usage: toggle_cfn_distributions.sh ORIGINDOMAINNAME'
fi 

toggle() {
    # Cloudfront distributions are created and deleted via Cloudformation, partly
    # because AWS CLI support for cloudfront is only available in a preview stage
    # (as of 2016/12/29)
    # One HAS TO delete the old distribution before creating a new one, because
    # the CNAME property has to be unique amongst distributions. 
    
    # For this reason, the DNS records have to be set to the origin 
    # server BEFORE starting the distribution swap!

    # Test this here:
    # TODO: test if dns records point to a plain (non-alias) A record
    cform_cfn_delete.sh
    aws cloudformation wait stack-delete-complete --stack-name $MYAWS_CFNSTACKNAME
    cform_cfn_create.sh $1
    aws cloudformation wait stack-create-complete --stack-name $MYAWS_CFNSTACKNAME
}

toggle $1
