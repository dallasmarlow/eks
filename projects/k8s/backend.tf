terraform {
	backend "s3" {
		bucket = "eks-test-tf-backend"
		region = "us-east-1"
		key = "k8s/terraform.tfstate"
		dynamodb_table = "terraform_state_lock"
	}

	required_providers {
		kubectl = {
			source = "gavinbunney/kubectl"
			version = ">= 1.7.0"
		}
	}

	required_version = ">= 0.13"
}

data "terraform_remote_state" "bastion" {
	backend = "s3"
	config = {
		bucket = "eks-test-tf-backend"
		region = "us-east-1"
		key = "bastion/terraform.tfstate"
		dynamodb_table = "terraform_state_lock"
	}
}

data "terraform_remote_state" "eks_cluster" {
	backend = "s3"
	config = {
		bucket = "eks-test-tf-backend"
		region = "us-east-1"
		key = "eks-cluster/terraform.tfstate"
		dynamodb_table = "terraform_state_lock"
	}
}

data "terraform_remote_state" "eks_compute" {
	backend = "s3"
	config = {
		bucket = "eks-test-tf-backend"
		region = "us-east-1"
		key = "eks-compute/terraform.tfstate"
		dynamodb_table = "terraform_state_lock"
	}
}

data "terraform_remote_state" "vpc" {
	backend = "s3"
	config = {
		bucket = "eks-test-tf-backend"
		region = "us-east-1"
		key = "vpc/terraform.tfstate"
		dynamodb_table = "terraform_state_lock"
	}
}
