terraform {
	backend "s3" {
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

data "terraform_remote_state" "ssh" {
	backend = "s3"
	config = {
		bucket = "eks-test-tf-backend"
		region = "us-east-1"
		key = "ssh/terraform.tfstate"
		dynamodb_table = "terraform_state_lock"
	}
}

data "terraform_remote_state" "terraform_backend" {
	backend = "s3"
	config = {
		bucket = "eks-test-tf-backend"
		region = "us-east-1"
		key = "terraform-backend/terraform.tfstate"
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