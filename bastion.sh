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

ec2-instance-connect-ssh $BASTION_ADDR "$@"