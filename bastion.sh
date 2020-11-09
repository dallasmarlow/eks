#!/usr/bin/env bash
set -e

if [[ -z $EKS_MGMT ]]; then
	echo "error: unsupported env"
	exit 1
fi

BASTION_SSH_USER="${BASTION_SSH_USER:-ec2-user}"
cd projects/bastion
BASTION_ADDR="$(terraform output bastion_ip)"
cd -

ec2-instance-connect-ssh $BASTION_ADDR "$@"