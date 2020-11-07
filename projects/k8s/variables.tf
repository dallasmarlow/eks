variable "cni_docker_img" {
	type = string
	default = "602401143452.dkr.ecr.us-west-2.amazonaws.com/amazon-k8s-cni:v1.7.5"
}

variable "cni_init_docker_img" {
	type = string
	default = "602401143452.dkr.ecr.us-west-2.amazonaws.com/amazon-k8s-cni-init:v1.7.5"
}