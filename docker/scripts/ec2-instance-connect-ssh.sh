#!/usr/bin/env bash
set -e
source "$(dirname $0)/ec2-instance-connect-common.sh"

EC2_FILTERS="${EC2_FILTERS} Name=ip-address,Values=$1"
JQ_QUERY=".Reservations[0].Instances[0]"

instance=$(aws ec2 describe-instances --filter $EC2_FILTERS --output json | jq -r $JQ_QUERY)
if [[ -z $instance ]]; then
	echo "error: unable to find running EC2 instance using ip address: $1"
	exit 1
fi

instance_id=$(echo $instance | jq -r '.InstanceId')
instance_az=$(echo $instance | jq -r '.Placement.AvailabilityZone')
aws ec2-instance-connect send-ssh-public-key \
	--availability-zone $instance_az \
	--instance-id $instance_id \
	--instance-os-user "${OS_USER}" \
	--ssh-public-key "file://${PUBLIC_SSH_KEY}"
ssh -A $OS_USER@$1