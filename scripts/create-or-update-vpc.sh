#!/bin/bash

script_name=$0

aws_cmd=${aws_cmd:-aws}

region=$($aws_cmd configure get region)
stack_name=""
cidr_block="10.0.0.0/16"
enable_dns_hostnames="false"
enable_dns_support="true"
instance_tenancy="default"
name_tag=""

s="Usage: $script_name"
s+=" --stack-name <The stack name>"
s+=" [ --cidr-block <The primary IPv4 CIDR block>"
s+=" --enable-dns-hostnames <true or false>"
s+=" --enable-dns-support <true or false>"
s+=" --instance-tenancy <dedicated, default or host"
s+=" --name-tag <value of 'Name' tag>"
s+=" --region <The region for the stack>"
s+=" --help ]"

display_usage() {
    echo $s
    echo ""
    echo "where"
    echo ""
    echo "  --help                  Display help."
    echo "  --stack-name            The name that is associated with the stack. The name must be unique in the region in which you are creating the stack."
    echo "  --cidr-block            The primary IPv4 CIDR block for the VPC."
    echo "  --enable-dns-hostnames  Indicates whether the instances launched in the VPC get DNS hostnames."
    echo "  --enable-dns-support    Indicates whether the DNS resolution is supported for the VPC."
    echo "  --instance-tenancy      The allowed tenancy of instances launched into the VPC."
    echo "  --name-tag              A tag with a key of 'Name' and a value that you specify."
    echo "  --region                The region for the stack."
    echo ""
}

while (( "$#" )); do
    if [[ ( $1 == "--help") ||  $1 == "-h" ]]; then 
	    display_usage
	    exit 0
    elif [[ (( $1 == "--stack-name") || $1 == "-s") && $# -ge 2 ]]; then
        shift
        stack_name=$1
    elif [[ (( $1 == "--cidr-block") || $1 == "-c") && $# -ge 2 ]]; then
        shift
        cidr_block=$1
    elif [[ (( $1 == "--enable-dns-hostnames") || $1 == "-edh") && $# -ge 2 ]]; then
        shift
        enable_dns_hostnames=$1
    elif [[ (( $1 == "--enable-dns-support") || $1 == "-eds") && $# -ge 2 ]]; then
        shift
        enable_dns_support=$1
    elif [[ (( $1 == "--instance-tenancy") || $1 == "-i") && $# -ge 2 ]]; then
        shift
        instance_tenancy=$1
    elif [[ (( $1 == "--name-tag") || $1 == "-n") && $# -ge 2 ]]; then
        shift
        name_tag=$1
    elif [[ (( $1 == "--region") || $1 == "-r") && $# -ge 2 ]]; then
        shift
        region=$1
    else
        display_usage
        exit 1
    fi
    shift
done

if [[ (-z $stack_name) ]]; then 
    display_usage
    exit 1
fi

if $aws_cmd cloudformation describe-stacks --region $region --stack-name $stack_name> /dev/null 2>&1 ; then
    create_or_update='update'
else
    create_or_update="create"
fi

$aws_cmd cloudformation ${create_or_update}-stack \
        --region $region \
        --stack-name $stack_name \
        --template-body file://../templates/vpc.yaml \
        --parameters \
            ParameterKey=CidrBlock,ParameterValue=$cidr_block \
            ParameterKey=EnableDnsHostnames,ParameterValue=$enable_dns_hostnames \
            ParameterKey=EnableDnsSupport,ParameterValue=$enable_dns_support \
            ParameterKey=InstanceTenancy,ParameterValue=$instance_tenancy \
            ParameterKey=NameTag,ParameterValue=$name_tag
