#!/usr/bin/env bash
set -e
source "$(dirname $0)/ec2-instance-connect-common.sh"

if [[ ! -z $1 ]]; then
	EC2_FILTERS="${EC2_FILTERS} Name=tag:Name,Values=$1"
fi

ec2_instances=$(aws ec2 describe-instances --filter ${EC2_FILTERS} --output json | jq  -c '.Reservations[].Instances | .[]')
for instance in $ec2_instances; do
	instance_id=$(echo $instance | jq -r '.InstanceId')
	instance_az=$(echo $instance | jq -r '.Placement.AvailabilityZone')
	echo $instance_id
	aws ec2-instance-connect send-ssh-public-key \
		--availability-zone $instance_az \
		--instance-id $instance_id \
		--instance-os-user "${OS_USER}" \
		--ssh-public-key "file://${PUBLIC_SSH_KEY}"
done