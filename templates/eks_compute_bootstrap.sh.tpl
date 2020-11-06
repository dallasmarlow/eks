#!/bin/bash
set -ex

exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1
	yum install -y ec2-instance-connect
	/etc/eks/bootstrap.sh ${CLUSTER_NAME} --b64-cluster-ca ${B64_CLUSTER_CA} --apiserver-endpoint ${API_SERVER_URL}