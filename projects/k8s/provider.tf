provider "aws" {
	region = var.region
}

provider "kubectl" {}

provider "kubernetes" {}

provider "kubernetes-alpha" {
	config_path = "~/.kube/config"
}