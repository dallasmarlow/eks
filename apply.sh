#!/usr/bin/env bash
set -e
projects=(terraform-backend vpc eks-cluster bastion route53 ecr)
for project in ${projects[@]}; do
	cd projects/$project
	terraform init
	terraform apply -auto-approve
	cd -
done