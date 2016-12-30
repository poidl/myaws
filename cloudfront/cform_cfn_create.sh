#!/bin/bash

errexit() {
    echo "*MYERROR* in $(basename $0): "$1 1>&2
    exit 1
}

[ ! -z $MYAWS_CFNTEMPLATE ] || errexit "MYAWS_CFNTEMPLATE not set"
[ ! -z $MYAWS_CFNSTACKNAME ] || errexit "MYAWS_CFNSTACKNAME not set"

if [ $# -ne 1 ]; then
    echo 'Usage: cform_cfn_create.sh ORIGINDOMAINNAME'
    exit 1
fi
echo "::Creating stack $MYAWS_CFNSTACKNAME with origin $1"

aws cloudformation create-stack \
    --stack-name $MYAWS_CFNSTACKNAME  \
    --parameters '[
        {
            "ParameterKey":"myOriginDomainName",
            "ParameterValue":"'$1'"
        }
    ]' \
    --template-body $MYAWS_CFNTEMPLATE