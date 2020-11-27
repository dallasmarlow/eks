#!/usr/bin/env bash
EC2_FILTERS="Name=instance-state-name,Values=running"
PUBLIC_SSH_KEY="${HOME}/.ssh/id_rsa.pub"
OS_USER="ec2-user"
