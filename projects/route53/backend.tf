terraform {
	backend "s3" {
		bucket = "eks-test-tf-backend"
		region = "us-east-1"
		key = "route53/terraform.tfstate"
		dynamodb_table = "terraform_state_lock"
	}
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