variable "account_id" {
	type = string
	default = "052780769609"
}

variable "bastion_arch" {
	type = string
	default = "arm64"
}

variable "bastion_ebs_volume_size" {
	type = number
	default = 10 # GB
}

variable "bastion_instance_type" {
	type = string
	default = "t4g.nano"
}

variable "ec2_user" {
	type = string
	default = "ec2-user"
}

variable "eks_version" {
	type = string
	default = "1.18"
}

variable "eks_compute_instance_type" {
	type = string
	default = "t3a.medium"
}

variable "kubectl_url" {
	type = string
	default = "https://amazon-eks.s3.us-west-2.amazonaws.com/1.18.8/2020-09-18/bin/linux/arm64/kubectl"
	# default = "https://amazon-eks.s3.us-west-2.amazonaws.com/1.18.8/2020-09-18/bin/linux/amd64/kubectl"
}

variable "kubelet_max_pods" {
	type = number
	default = 12
}

variable "region" {
	type = string
	default = "us-east-2"
}

variable "terraform_url" {
	type = string
	default = "https://releases.hashicorp.com/terraform/0.13.5/terraform_0.13.5_linux_arm64.zip"
	# default = "https://releases.hashicorp.com/terraform/0.13.5/terraform_0.13.5_linux_amd64.zip"
}

variable "remote_network" {
	type = string
	default = "104.162.77.104/32"
}

variable "eks_vpc_network" {
	type = string
	default = "10.200.100.0/26"
}

variable "eks_priv_subnet_a_network" {
	type = string
	default = "10.200.100.0/28"
}

variable "eks_priv_subnet_b_network" {
	type = string
	default = "10.200.100.16/28"
}

variable "eks_pub_subnet_a_network" {
	type = string
	default = "10.200.100.32/28"
}

variable "eks_pub_subnet_b_network" {
	type = string
	default = "10.200.100.48/28"
}

variable "k8s_pod_network" {
	type = string
	default = "100.64.0.0/20"
}

variable "k8s_pod_subnet_a_network" {
	type = string
	default = "100.64.0.0/21"
}

variable "k8s_pod_subnet_b_network" {
	type = string
	default = "100.64.8.0/21"
}

variable "eks_cluster_name" {
	type = string
	default = "eks-test"
}

variable "route53_zone_domain" {
	type = string
	default = "cl0wn.shoes"
}
