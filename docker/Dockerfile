FROM debian:buster-slim

ENV EKS_MGMT 1

RUN apt-get update && \
	apt-get install -y \
	curl dnsutils git golang groff jq less python3-pip ssh vim zip && \
	apt-get clean
RUN pip3 install awscli

# RUN curl -o helm.tgz https://get.helm.sh/helm-v3.5.4-linux-amd64.tar.gz && \
# 	tar xfvz helm.tgz && \
# 	mv linux-amd64/helm /usr/local/bin && \
# 	rm -rf helm.tgz linux-amd64

RUN ssh-keygen -t rsa -q -f "$HOME/.ssh/id_rsa" -N ""

RUN curl -o terraform.zip https://releases.hashicorp.com/terraform/1.1.7/terraform_1.1.7_linux_amd64.zip && \
	unzip -d /tmp/terraform terraform.zip && \
	mv /tmp/terraform/terraform /usr/local/bin/ && \
	chmod +x /usr/local/bin/terraform && \
	rm -f terraform.zip

COPY scripts/ec2-instance-connect-common.sh /usr/local/bin/ec2-instance-connect-common.sh
COPY scripts/ec2-instance-connect-send-key.sh /usr/local/bin/ec2-instance-connect-send-key
COPY scripts/ec2-instance-connect-ssh.sh /usr/local/bin/ec2-instance-connect-ssh
RUN chmod +x /usr/local/bin/ec2-instance-connect-*

WORKDIR /opt
