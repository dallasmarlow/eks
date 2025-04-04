#!/bin/bash
set -e
set -x

exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1
	region=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)

	# setup awscli
	mkdir /home/ec2-user/.aws
	cat > /home/ec2-user/.aws/config <<EOL
[default]
region = $region
EOL

	# setup helm
	curl -o helm.tgz ${HELM_URL} && \
		tar xfvz helm.tgz && \
		mv linux-*/helm /usr/local/bin && \
		rm -rfv helm.tgz linux-*

	# setup kubectl
	curl -o /usr/local/bin/kubectl ${KUBECTL_URL}
	chmod +x /usr/local/bin/kubectl
	aws eks update-kubeconfig \
		--kubeconfig /home/ec2-user/.kube/config \
		--name ${CLUSTER_NAME} \
		--region $region

	# setup kubectl-proxy unit
	cat > /lib/systemd/system/kubectl-proxy.service <<EOL
[Unit]
Description=kubectl proxy
After=network.target

[Service]
User=ec2-user
ExecStart=/bin/bash -c "/usr/local/bin/kubectl proxy"
StartLimitInterval=0
RestartSec=10
Restart=always
EOL
	systemctl daemon-reload
	systemctl enable kubectl-proxy.service

	# setup ssh key
	mkdir -p /home/ec2-user/.ssh && \
		ssh-keygen -t rsa -q -f /home/ec2-user/.ssh/id_rsa -N "" && \
		chmod 700 /home/ec2-user/.ssh && \
		chown ec2-user.ec2-user /home/ec2-user/.ssh/id_rsa*

	# pkg install
	amazon-linux-extras enable docker
	yum install -y amazon-ecr-credential-helper docker ec2-instance-connect jq

	# setup docker
	systemctl daemon-reload
	systemctl enable docker
	systemctl start docker
	usermod -a -G docker ec2-user
	mkdir -p /home/ec2-user/.docker
	echo '{"credsStore": "ecr-login"}' > /home/ec2-user/.docker/config.json

	# setup terraform
	curl -o terraform.zip ${TERRAFORM_URL} && \
		unzip -d /usr/local/bin terraform.zip && \
		rm -f terraform.zip

	# fetch utils
	aws s3 cp s3://${S3_BUCKET}/ec2-instance-connect-common.sh /usr/local/bin
	aws s3 cp s3://${S3_BUCKET}/ec2-instance-connect-send-key /usr/local/bin
	aws s3 cp s3://${S3_BUCKET}/ec2-instance-connect-ssh /usr/local/bin
	aws s3 cp s3://${S3_BUCKET}/list-eks-admin-token /usr/local/bin
	chmod +x /usr/local/bin/ec2-instance-connect-* \
		/usr/local/bin/list-eks-admin-token