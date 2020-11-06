#!/usr/bin/env bash
set -e

# exclude the route53 project as an existing zone needs to be imported manually
projects=(terraform-backend vpc eks-cluster bastion ecr)
for project in ${projects[@]}; do
	cd projects/$project
	terraform init
	terraform apply -auto-approve
	cd -
done