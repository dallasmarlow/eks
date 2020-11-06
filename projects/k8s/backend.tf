terraform {
	backend "s3" {
		bucket = "eks-test-tf-backend"
		region = "us-east-2"
		key = "k8s/terraform.tfstate"
		dynamodb_table = "terraform_state_lock"
	}
}

data "terraform_remote_state" "bastion" {
	backend = "s3"
	config = {
		bucket = "eks-test-tf-backend"
		region = "us-east-2"
		key = "bastion/terraform.tfstate"
		dynamodb_table = "terraform_state_lock"
	}
}

data "terraform_remote_state" "eks" {
	backend = "s3"
	config = {
		bucket = "eks-test-tf-backend"
		region = "us-east-2"
		key = "eks-cluster/terraform.tfstate"
		dynamodb_table = "terraform_state_lock"
	}
}