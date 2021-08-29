#!/usr/bin/env bash
set -e
DATE_FMT="%Y-%m-%dT%H:%M:%SZ"
MIN_ASG_INSTANCES=${MIN_ASG_INSTANCES:-0}
OUTPUT_KEY=${OUTPUT_KEY:-asg_name}
REFRESH_WARMUP_INTERVAL=${REFRESH_WARMUP_INTERVAL:-60}
COMPUTE_USAGE="usage: $0 <activity|describe|refresh|scale <num_instances>|scale-interval <num_instances> <hours>>"

if [[ -z $1 ]]; then
	echo $COMPUTE_USAGE
	exit 1
fi

cd projects/eks-compute
ASG_NAME=$(terraform output -json | jq -r ".${OUTPUT_KEY}.value")
cd -

if [[ -z $ASG_NAME ]]; then
	echo "unable to detect auto-scaling group from terraform eks-compute outputs"
	exit 1
fi

case $1 in
	activity)
		aws autoscaling describe-scaling-activities \
			--auto-scaling-group-name $ASG_NAME
		;;
	describe)
		aws autoscaling describe-auto-scaling-groups \
			--auto-scaling-group-name $ASG_NAME
		;;
	refresh)
		aws autoscaling start-instance-refresh \
			--auto-scaling-group-name $ASG_NAME \
			--preferences "{\"InstanceWarmup\": $REFRESH_WARMUP_INTERVAL}"
		;;
	scale)
		instances=${2:-1}
		aws autoscaling set-desired-capacity \
			--auto-scaling-group-name $ASG_NAME \
			--desired-capacity $instances
		;;
	scale-interval)
		instances=${2:-1}
		interval=${3:-1}
		aws autoscaling put-scheduled-update-group-action \
			--auto-scaling-group-name $ASG_NAME \
			--desired-capacity $instances \
			--scheduled-action-name eks-compute-scale-up \
			--start-time $(date -d "+3 second" -u +$DATE_FMT)
		aws autoscaling put-scheduled-update-group-action \
			--auto-scaling-group-name $ASG_NAME \
			--min-size $MIN_ASG_INSTANCES \
			--desired-capacity $MIN_ASG_INSTANCES \
			--scheduled-action-name eks-compute-scale-down \
			--start-time $(date -d "+${interval} hour" -u +$DATE_FMT)
		;;
	*)
		echo $COMPUTE_USAGE
		exit 1
esac
