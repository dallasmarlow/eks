variable "account_id" {
	type = string
	default = "052780769609"
}

variable "bastion_instance_type" {
	type = string
	default = "t3a.small"
}

variable "eks_version" {
	type = string
	default = "1.18"
}

variable "eks_worker_instance_type" {
	type = string
	default = "t3a.large"
}

variable "kubectl_url" {
	type = string
	default = "https://amazon-eks.s3.us-west-2.amazonaws.com/1.18.8/2020-09-18/bin/linux/amd64/kubectl"
}

variable "region" {
	type = string
	default = "us-east-2"
}

variable "ssh_key" {
	type = string
	default = "eks-test"
}

variable "terraform_url" {
	type = string
	default = "https://releases.hashicorp.com/terraform/0.13.5/terraform_0.13.5_linux_amd64.zip"
}

variable "remote_network" {
	type = string
	default = "104.162.77.104/32"
}

variable "eks_vpc_network" {
	type = string
	default = "10.253.195.64/26"
}

variable "k8s_pod_network" {
	type = string
	default = "100.64.0.0/20"
}

variable "eks_cluster_name" {
	type = string
	default = "eks-test"
}

variable "route53_zone_domain" {
	type = string
	default = "cl0wn.shoes"
}