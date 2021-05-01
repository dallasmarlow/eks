#!/usr/bin/env bash
set -e

if [[ -z $EKS_MGMT ]]; then
	echo "error: unsupported env"
	exit 1
fi

BASTION_SSH_USER="${BASTION_SSH_USER:-ec2-user}"
cd projects/bastion
BASTION_ADDR="$(terraform output -json | jq -r .bastion_ip.value)"
cd -

if [[ -z $BASTION_ADDR ]]; then
	echo "error: unable to detect bastion address from terraform outputs"
	exit 1
fi

echo "starting kubectl proxy..."
ec2-instance-connect-ssh $BASTION_ADDR sudo systemctl start kubectl-proxy.service

echo "starting ssh tunnel..."
ec2-instance-connect-send-key $BASTION_ADDR
ssh -L 8001:127.0.0.1:8001 "$BASTION_SSH_USER@$BASTION_ADDR" -N