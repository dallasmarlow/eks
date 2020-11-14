#!/usr/bin/env bash
set -e

if [[ -z $1 ]]; then
	echo "usage: $0 <apply|destroy> <optional project dir name>"
	exit 1
fi

optional_projects=(route53 ecr)
if [[ -z $2 ]]; then
	projects=(terraform-backend vpc ssh eks-cluster eks-compute bastion)
	if [[ -z $SKIP_OPTIONAL_PROJECTS ]]; then
		for project in ${optional_projects[@]}; do
			projects[${#projects[@]}]=$project
		done
	fi
else
	projects=($2)
fi


if [[ $1 = "clean" ]]; then
	for project in ${projects[@]}; do
		echo "removing local terraform state for project: ${project}"
		cd projects/$project
		rm -frv errored.tfstate terraform.tfstate* .terraform
		cd -
	done
elif [[ $1 = "destroy" ]]; then
	for (( i=${#projects[@]}-1 ; i >= 0 ; i-- )); do
		project=${projects[i]}
		echo "destroying project: ${project}"
		cd projects/$project

		# retain route53 zone
		if [[ $project = "route53" ]]; then
			terraform destroy -auto-approve -target aws_route53_record.bastion
		else
			terraform destroy -auto-approve
		fi

		rm -frv .terraform
		cd -
	done
else # apply
	for project in ${projects[@]}; do
		echo "applying project: ${project}"
		cd projects/$project
		terraform init
		terraform plan
		terraform apply -auto-approve
		cd -
	done
fi