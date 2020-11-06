terraform {
	backend "s3" {
		bucket = "eks-test-tf-backend"
		region = "us-east-2"
		key = "ecr/terraform.tfstate"
		dynamodb_table = "terraform_state_lock"
	}
}