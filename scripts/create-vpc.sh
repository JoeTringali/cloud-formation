#!/bin/bash

script_name=$0

aws_cmd=${aws_cmd:-aws}

stack_name=""
cidr_block="10.0.0.0/16"
enable_dns_hostnames="false"
enable_dns_support="true"
instance_tenancy="default"
name_tag=""

s="usage: $script_name"
s+="  --stack-name <The stack name>"
s+=" [ --cidr_block <The primary IPv4 CIDR block>"
s+=" --enable_dns_hostnames <true or false>"
s+=" --enable_dns_support <true or false>"
s+=" --instance_tenancy <dedicated, default or host"
s+=" --name_tag <value of 'Name' tag>"
s+=" --help ]"

display_usage() {
    echo $s
    echo ""
    echo "  --help                  Display help."
    echo "  --stack-name            The name that is associated with the stack. The name must be unique in the region in which you are creating the stack."
    echo "  --cidr_block            The primary IPv4 CIDR block for the VPC."
    echo "  --enable_dns_hostnames  Indicates whether the instances launched in the VPC get DNS hostnames."
    echo "  --enable_dns_support    Indicates whether the DNS resolution is supported for the VPC."
    echo "  --instance_tenancy      The allowed tenancy of instances launched into the VPC."
    echo "  --name_tag              A tag with a key of 'Name' and a value that you specify."
    echo ""
}

while (( "$#" )); do
    if [[ ( $1 == "--help") ||  $1 == "-h" ]]; then 
	    display_usage
	    exit 0
    elif [[ (( $1 == "--stack-name") || $1 == "-s") && $# -ge 2 ]]; then
        shift
        stack_name=$1
    elif [[ (( $1 == "--cidr_block") || $1 == "-c") && $# -ge 2 ]]; then
        shift
        cidr_block=$1
    elif [[ (( $1 == "--enable_dns_hostnames") || $1 == "-edh") && $# -ge 2 ]]; then
        shift
        enable_dns_hostnames=$1
    elif [[ (( $1 == "--enable_dns_support") || $1 == "-eds") && $# -ge 2 ]]; then
        shift
        enable_dns_support=$1
    elif [[ (( $1 == "--instance_tenancy") || $1 == "-i") && $# -ge 2 ]]; then
        shift
        instance_tenancy=$1
    elif [[ (( $1 == "--name_tag") || $1 == "-n") && $# -ge 2 ]]; then
        shift
        name_tag=$1
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

$aws_cmd cloudformation create-stack --stack-name $stack_name \
        --template-body file://../templates/vpc.yaml \
        --parameters \
            ParameterKey=pCidrBlock,ParameterValue=$cidr_block \
            ParameterKey=pEnableDnsHostnames,ParameterValue=$enable_dns_hostnames \
            ParameterKey=pEnableDnsSupport,ParameterValue=$enable_dns_support \
            ParameterKey=pInstanceTenancy,ParameterValue=$instance_tenancy \
            ParameterKey=pNameTag,ParameterValue=$name_tag
