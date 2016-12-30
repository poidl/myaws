#!/bin/bash

case "$1" in
    list)
        echo "::Listing stacks"
        aws cloudformation describe-stacks \
                --query 'Stacks[].[StackName, StackStatus]' \
                --output text
        ;;
    events)
        echo "::Displaying stack events"
        aws cloudformation describe-stack-events \
            --stack-name $2 \
            --query 'StackEvents[].[ResourceType, ResourceStatus]' \
            --output text
        ;;
    delete)
        echo "::Deleting stack"
        aws cloudformation delete-stack \
            --stack-name $2 \
        ;;
    *)
        echo 'Usage: cfrnt_stacks.sh list|events|delete'
        exit 1
esac

