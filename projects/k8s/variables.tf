variable "cni_docker_img" {
	type = string
	default = "602401143452.dkr.ecr.us-east-1.amazonaws.com/amazon-k8s-cni:v1.7.5-eksbuild.1"
	# default = "602401143452.dkr.ecr.us-west-2.amazonaws.com/amazon-k8s-cni:v1.7.5"
}

variable "cni_init_docker_img" {
	type = string
	default = "602401143452.dkr.ecr.us-east-1.amazonaws.com/amazon-k8s-cni-init:v1.7.5-eksbuild.1"
	# default = "602401143452.dkr.ecr.us-west-2.amazonaws.com/amazon-k8s-cni-init:v1.7.5"
}

variable "cni_custom_network_cfg" {
	type = string
	default = "true"
}

variable "cni_eni_config_label" {
	type = string
	default = "topology.kubernetes.io/zone"
}

variable "kubernetes_dashboard_chart_version" {
	type = string
	default = "3.0.0"
}

variable "lb_controller_chart_version" {
	type = string
	default = "1.0.8"
}

variable "lb_controller_service_account_name" {
	type = string
	default = "aws-load-balancer-controller"
}

variable "metrics_server_docker_img" {
	type = string
	default = "k8s.gcr.io/metrics-server/metrics-server:v0.3.7"
}

variable "region" {
	type = string
	default = "us-east-1"
}