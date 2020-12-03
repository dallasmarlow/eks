terraform {
	backend "s3" {
		bucket = "eks-test-tf-backend"
		region = "us-east-1"
		key = "eks-cluster/terraform.tfstate"
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