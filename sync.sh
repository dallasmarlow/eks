#!/usr/bin/env bash
BASTION_SSH_USER="${BASTION_SSH_USER:-ec2-user}"
cd projects/bastion
BASTION_ADDR="$(terraform output bastion_ip)"
cd -

scp -Cr projects templates $BASTION_SSH_USER@$BASTION_ADDR:~/
