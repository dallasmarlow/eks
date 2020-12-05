#!/usr/bin/env bash
set -e
CHARTS=(
	"https://aws.github.io/eks-charts/|eks|aws-load-balancer-controller|1.1.0"
	"https://kubernetes.github.io/dashboard/|kubernetes-dashboard|kubernetes-dashboard|3.0.0"
)

for chart in "${CHARTS[@]}"; do
	repo_url="$(echo $chart | cut -d '|' -f 1)"
	repo_name="$(echo $chart | cut -d '|' -f 2)"
	chart_name="$(echo $chart | cut -d '|' -f 3)"
	chart_version="$(echo $chart | cut -d '|' -f 4)"

	# fetch charts
	if [[ ! -f "$chart_name-$chart_version.tgz" ]]; then
		helm repo add $repo_name $repo_url --force-update
		helm pull "$repo_name/$chart_name" --version $chart_version
	fi
done

helm repo index .