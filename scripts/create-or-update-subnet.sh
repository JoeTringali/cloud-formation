#!/bin/bash

script_name=$0

aws_cmd=${aws_cmd:-aws}

region=$($aws_cmd configure get region)
stack_name=""
assign_ipv6_address_on_creation="false"
availability_zone=""
cidr_block=""
ipv6_cidr_block=""
map_public_ip_on_launch="false"
name_tag=""
vpc_id=""

s="Usage: $script_name"
s+="  --stack-name <The stack name>"
s+=" [ --assign-ipv6-address-on-creation <true or false>"
s+=" --availability-zone <The Availability Zone of the subnet."
s+=" --cidr-block <The IPv4 CIDR block assigned to the subnet>"
s+=" --ipv6-cidr-block <The IPv6 CIDR block assigned to the subnet>"
s+=" --map-public-ip-on-launch <true or false>"
s+=" --name-tag <value of 'Name' tag>"
s+=" --vpc-id <The ID of the VPC the subnet is in>"
s+=" --region <The region for the stack>"
s+=" --help ]"

display_usage() {
    echo $s
    echo ""
    echo "where"
    echo ""
    echo "  --help                             Display help."
    echo "  --stack-name                       The name that is associated with the stack. The name must be unique in the region in which you are creating the stack."
    echo "  --assign-ipv6-address-on-creation  Indicates whether a network interface created in this subnet receives an IPv6 address."
    echo "  --availability-zone                The Availability Zone of the subnet."
    echo "  --cidr-block                       The IPv4 CIDR block assigned to the subnet."
    echo "  --ipv6-cidr-block                  The IPv6 CIDR block assigned to the subnet."
    echo "  --map-public-ip-on-launch          Indicates whether instances launched in this subnet receive a public IPv4 address."
    echo "  --name-tag                         A tag with a key of 'Name' and a value that you specify."
    echo "  --vpc-id                           The ID of the VPC the subnet is in."
    echo "  --region                           The region for the stack."
    echo ""
}

while (( "$#" )); do
    if [[ ( $1 == "--help") ||  $1 == "-h" ]]; then 
	    display_usage
	    exit 0
    elif [[ (( $1 == "--stack-name") || $1 == "-s") && $# -ge 2 ]]; then
        shift
        stack_name=$1
    elif [[ (( $1 == "--assign-ipv6-address-on-creation") || $1 == "-aiaoc") && $# -ge 2 ]]; then
        shift
        assign_ipv6_address_on_creation=$1
    elif [[ (( $1 == "--availability-zone") || $1 == "-az") && $# -ge 2 ]]; then
        shift
        availability_zone=$1
    elif [[ (( $1 == "--cidr-block") || $1 == "-c") && $# -ge 2 ]]; then
        shift
        cidr_block=$1
    elif [[ (( $1 == "--ipv6-cidr-block") || $1 == "-i") && $# -ge 2 ]]; then
        shift
        ipv6_cidr_block=$1
    elif [[ (( $1 == "--map-public-ip-on-launch") || $1 == "-m") && $# -ge 2 ]]; then
        shift
        map_public_ip_on_launch=$1
    elif [[ (( $1 == "--name-tag") || $1 == "-n") && $# -ge 2 ]]; then
        shift
        name_tag=$1
    elif [[ (( $1 == "--vpc-id") || $1 == "-v") && $# -ge 2 ]]; then
        shift
        vpc_id=$1
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
        --template-body file://../templates/subnet.yaml \
        --parameters \
            ParameterKey=pAssignIpv6AddressOnCreation,ParameterValue=$assign_ipv6_address_on_creation \
            ParameterKey=pAvailabilityZone,ParameterValue=$availability_zone \
            ParameterKey=pCidrBlock,ParameterValue=$cidr_block \
            ParameterKey=pIpv6CidrBlock,ParameterValue=$ipv6_cidr_block \
            ParameterKey=pMapPublicIpOnLaunch,ParameterValue=$map_public_ip_on_launch \
            ParameterKey=pNameTag,ParameterValue=$name_tag \
            ParameterKey=pVpcId,ParameterValue=$vpc_id 
