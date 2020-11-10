#!/usr/bin/env bash
set -e
source "$(dirname $0)/ec2-instance-connect-common.sh"

# process input
if [[ $1 =~ ^i-[0-9a-f]+$ ]]; then
	EC2_FILTERS="${EC2_FILTERS} Name=instance-id,Values=${1}"
else
	if [[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
		EC2_IP=$1
	else
		EC2_IP=$(dig +short $1)
		if [[ -z $EC2_IP ]]; then
			echo "error: unable to resolve target address: $1"
			exit 1
		fi
	fi

	if [[ -z $EKS_MGMT ]]; then # assume running from bastion and w/i VPC
		EC2_FILTERS="${EC2_FILTERS} Name=network-interface.addresses.private-ip-address,Values=${EC2_IP}"
	else # assume running w/i EKS management container outside of VPC
		EC2_FILTERS="${EC2_FILTERS} Name=ip-address,Values=${EC2_IP}"
	fi
fi

jq_query=".Reservations[0].Instances[0]"
instance=$(aws ec2 describe-instances --filter $EC2_FILTERS --output json | jq -r $jq_query)
if [[ -z $instance ]]; then
	echo "error: unable to find running EC2 instance: $1"
	exit 1
fi

instance_id=$(echo $instance | jq -r '.InstanceId')
instance_az=$(echo $instance | jq -r '.Placement.AvailabilityZone')
if [[ -z $EC2_IP ]]; then
	if [[ -z $EKS_MGMT ]]; then # assume running from bastion and w/i VPC
		EC2_IP=$(echo $instance | jq -r '.PrivateIpAddress')
	else # assume running w/i EKS management container outside of VPC
		EC2_IP=$(echo $instance | jq -r '.PublicIpAddress')
	fi
fi

aws ec2-instance-connect send-ssh-public-key \
	--availability-zone $instance_az \
	--instance-id $instance_id \
	--instance-os-user "${OS_USER}" \
	--ssh-public-key "file://${PUBLIC_SSH_KEY}"
ssh -Att $OS_USER@$EC2_IP "${@:2}"