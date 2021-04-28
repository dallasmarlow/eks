#!/usr/bin/env bash

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

if [[ -z $SKIP_SEND_KEY ]]; then
	ec2-instance-connect-send-key bastion
fi

scp -Cr projects/k8s $BASTION_SSH_USER@$BASTION_ADDR:~/
