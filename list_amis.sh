#!/bin/bash

# Adapted from J. Saryerwinnie's talk https://www.youtube.com/watch?v=TnfqJYPjD9I

list_amis() {
    local region_name="$1"
    aws ec2 describe-images \
        --filters \
            Name=owner-alias,Values=amazon \
            Name=name,Values="amzn-ami-hvm-*" \
            Name=architecture,Values=x86_64 \
            Name=virtualization-type,Values=hvm \
            Name=root-device-type,Values=ebs \
            Name=block-device-mapping.volume-type,Values=gp2 \
        --region "$region_name" \
        --query "reverse(sort_by(Images[? !contains(Name, 'rc')], &CreationDate))
                [*].['$region_name',ImageId,Name,Description]" \
        --output text
}

if [ -z "$1" ]; then
    for region_name in $(aws ec2 describe-regions --query \
        "sort(Regions[].RegionName)" --output text); do
        list_amis $region_name
    done
else
    case "$1" in
        -r|--region)
            shift
            region_name="$1"
            ;;
        *)
            echo "usage: list_amis [-r | --region]" 1>&2
            exit 1
    esac
    list_amis "$region_name"
fi
                            
