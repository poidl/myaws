#!/bin/bash

errexit() {
    echo "*MYERROR* in $(basename $0): "$1 1>&2
    exit 1
}

[ ! -z $MYAWS_CFNSTACKNAME ] || errexit "MYAWS_CFNSTACKNAME not set"

echo "::Deleting stack $MYAWS_CFNSTACKNAME"

aws cloudformation delete-stack \
    --stack-name $MYAWS_CFNSTACKNAME

