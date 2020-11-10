provider "aws" {
	region = var.region
}

provider "helm" {
	kubernetes {
		config_path = "~/.kube/config"
	}
}

# https://github.com/gavinbunney/terraform-provider-kubectl
provider "kubectl" {}

provider "kubernetes" {}

provider "kubernetes-alpha" {
	config_path = "~/.kube/config"
}