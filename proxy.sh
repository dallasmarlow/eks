#!/usr/bin/env bash
set -e
AWS_REGION="${AWS_REGION:-us-east-2}"
PUBLIC_SSH_KEY="${HOME}/.ssh/id_rsa.pub"

if [ ! -z $EKS_MGMT ]; then
	echo "error: unsupported env"
	exit 1
fi

BASTION_SSH_USER="${BASTION_SSH_USER:-ec2-user}"
cd projects/bastion
BASTION_ADDR="$(terraform output -json | jq -r .eip.value)"
cd -

if [ -z $BASTION_ADDR ]; then
	echo "error: unable to detect bastion address from terraform outputs"
	exit 1
fi

ec2_filters="Name=instance-state-name,Values=running Name=ip-address,Values=${BASTION_ADDR}"
jq_query=".Reservations[0].Instances[0]"
instance=$(aws ec2 describe-instances --filter $ec2_filters --output json --region $AWS_REGION | jq -r $jq_query)

if [ -z $instance ]; then
	echo "error: unable to find running EC2 instance: $1"
	exit 1
fi

instance_id=$(echo $instance | jq -r '.InstanceId')
instance_az=$(echo $instance | jq -r '.Placement.AvailabilityZone')

echo "starting kubectl proxy..."
aws ec2-instance-connect send-ssh-public-key \
	--availability-zone $instance_az \
	--instance-id $instance_id \
	--instance-os-user "${BASTION_SSH_USER}" \
	--region "${AWS_REGION}" \
	--ssh-public-key "file://${PUBLIC_SSH_KEY}"
ssh -Att -l $BASTION_SSH_USER $BASTION_ADDR "sudo systemctl start kubectl-proxy.service"

echo "starting ssh tunnel..."
aws ec2-instance-connect send-ssh-public-key \
	--availability-zone $instance_az \
	--instance-id $instance_id \
	--instance-os-user "${BASTION_SSH_USER}" \
	--region "${AWS_REGION}" \
	--ssh-public-key "file://${PUBLIC_SSH_KEY}"
ssh -L 8001:127.0.0.1:8001 "$BASTION_SSH_USER@$BASTION_ADDR" -N