#!/usr/bin/env bash
set -e
source "$(dirname $0)/ec2-instance-connect-common.sh"

if [[ ! -z "$1" ]]; then
	if [[ $1 =~ ^i-[0-9a-f]+$ ]]; then
		EC2_FILTERS="${EC2_FILTERS} Name=instance-id,Values=$1"
	elif [[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
		EC2_FILTERS="${EC2_FILTERS} Name=ip-address,Values=$1"
	else
		EC2_FILTERS="${EC2_FILTERS} Name=tag:Name,Values=$1"
	fi
fi

ec2_instances=$(aws ec2 describe-instances --filter ${EC2_FILTERS} --output json | jq  -c '.Reservations[].Instances | .[]')
for instance in ${ec2_instances[@]}; do
	instance_id=$(echo $instance | jq -r '.InstanceId')
	instance_az=$(echo $instance | jq -r '.Placement.AvailabilityZone')
	echo $instance_id
	aws ec2-instance-connect send-ssh-public-key \
		--availability-zone $instance_az \
		--instance-id $instance_id \
		--instance-os-user "${OS_USER}" \
		--ssh-public-key "file://${PUBLIC_SSH_KEY}"
done