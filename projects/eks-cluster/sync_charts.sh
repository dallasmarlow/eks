#!/usr/bin/env bash
set -e
REMOTE_CHARTS=(
	"https://aws.github.io/eks-charts/|eks|aws-load-balancer-controller|1.1.0"
	"https://kubernetes.github.io/dashboard/|kubernetes-dashboard|kubernetes-dashboard|3.0.0"
)
S3_BUCKET=$(terraform output -json | jq -r .s3_bucket_helm_repo.value)

if [[ ! -d "./charts" ]]; then
	mkdir charts
fi
cd charts

for chart in "${REMOTE_CHARTS[@]}"; do
	repo_url="$(echo $chart | cut -d '|' -f 1)"
	repo_name="$(echo $chart | cut -d '|' -f 2)"
	chart_name="$(echo $chart | cut -d '|' -f 3)"
	chart_version="$(echo $chart | cut -d '|' -f 4)"
	chart_file="$chart_name-$chart_version.tgz"

	set +e
	remote_status="$(aws s3api head-object --bucket $S3_BUCKET --key $chart_file 2>&1)"
	set -e


	if [[ "$remote_status" =~ "Not Found" ]]; then
		# fetch
		if [[ ! -f "$chart_file" ]]; then
			helm repo add "$repo_name" "$repo_url" --force-update
			helm pull "$repo_name/$chart_name" --version "$chart_version"
		fi

		# upload
		aws s3 cp "$chart_file" "s3://$S3_BUCKET/$chart_file" --acl public-read
	else
		aws s3 cp "s3://$S3_BUCKET/$chart_file" .
	fi
done

# index
helm repo index .
aws s3 cp index.yaml "s3://$S3_BUCKET/index.yaml" --acl public-read --content-type "text/yaml"

cd -
