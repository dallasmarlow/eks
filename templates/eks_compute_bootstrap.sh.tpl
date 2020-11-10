#!/bin/bash
set -ex

exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1
	yum install -y ec2-instance-connect iptables-services

	# block IMDS access for containers running w/o host networking mode enabled
	# https://docs.aws.amazon.com/eks/latest/userguide/best-practices-security.html
	iptables --insert FORWARD 1 --in-interface eni+ --destination 169.254.169.254/32 --jump DROP

	# uncomment the following command if/when using ENI trunking / security groups per-pod
	# iptables -t mangle -A POSTROUTING -o vlan+ --destination 169.254.169.254/32 --jump DROP

	iptables-save | tee /etc/sysconfig/iptables 
	systemctl enable --now iptables

	/etc/eks/bootstrap.sh ${CLUSTER_NAME} --b64-cluster-ca ${B64_CLUSTER_CA} --apiserver-endpoint ${API_SERVER_URL}