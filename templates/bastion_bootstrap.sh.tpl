#!/bin/bash -xe
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1
	# pkg install
	amazon-linux-extras enable docker
	yum install -y amazon-ecr-credential-helper docker ec2-instance-connect

	# setup docker
	systemctl daemon-reload
	systemctl enable docker
	systemctl start docker
	usermod -a -G docker ec2-user
	mkdir -p /home/ec2-user/.docker
	echo '{"credsStore": "ecr-login"}' > /home/ec2-user/.docker/config.json

	# setup kubectl
	mkdir -p /home/ec2-user/.local/bin
	curl -o /home/ec2-user/.local/bin/kubectl ${KUBECTL_URL}
	chmod +x /home/ec2-user/.local/bin/kubectl
	aws eks update-kubeconfig \
		--kubeconfig /home/ec2-user/.kube/config \
		--name ${CLUSTER_NAME} \
		--region $(curl -s http://169.254.169.254/latest/meta-data/placement/region)

	# setup terraform
	curl -o terraform.zip ${TERRAFORM_URL} && \
		unzip -d /home/ec2-user/.local/bin terraform.zip && \
		rm -f terraform.zip