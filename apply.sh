#!/usr/bin/env bash
set -e

optional_projects=(route53 ecr)
if [[ -z $1 ]]; then
	projects=(terraform-backend vpc eks-cluster eks-compute bastion)
	if [[ -z $SKIP_OPTIONAL_PROJECTS ]]; then
		for project in ${optional_projects[@]}; do
			projects[${#projects[@]}]=$project
		done
	fi
else
	projects=($1)
fi

for project in ${projects[@]}; do
	cd projects/$project
	terraform init
	terraform apply -auto-approve
	cd -
done
