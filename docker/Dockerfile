FROM debian:latest

RUN apt-get update && \
	apt-get install -y \
	curl vim groff jq less python-pip ssh zip && pip install awscli
RUN ssh-keygen -t rsa -q -f "$HOME/.ssh/id_rsa" -N ""
RUN curl -o /usr/local/bin/kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.18.8/2020-09-18/bin/linux/amd64/kubectl && chmod +x /usr/local/bin/kubectl
RUN curl -o terraform.zip https://releases.hashicorp.com/terraform/0.13.5/terraform_0.13.5_linux_amd64.zip && \
	unzip -d /tmp/terraform terraform.zip && \
	mv /tmp/terraform/terraform /usr/local/bin/ && \
	chmod +x /usr/local/bin/terraform && \
	rm -f terraform.zip

COPY scripts/ec2-instance-connect-common.sh /usr/local/bin/ec2-instance-connect-common.sh
COPY scripts/ec2-instance-connect-send-key.sh /usr/local/bin/ec2-instance-connect-send-key
COPY scripts/ec2-instance-connect-ssh.sh /usr/local/bin/ec2-instance-connect-ssh
RUN chmod +x /usr/local/bin/ec2-instance-connect-*

WORKDIR /opt