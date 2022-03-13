terraform {
  backend "s3" {
    bucket         = "eks-test-tf-backend"
    region         = "us-east-2"
    key            = "lambda/terraform.tfstate"
    dynamodb_table = "terraform_state_lock"
  }
}

data "terraform_remote_state" "eks_cluster" {
  backend = "s3"
  config = {
    bucket         = "eks-test-tf-backend"
    region         = "us-east-2"
    key            = "eks-cluster/terraform.tfstate"
    dynamodb_table = "terraform_state_lock"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket         = "eks-test-tf-backend"
    region         = "us-east-2"
    key            = "vpc/terraform.tfstate"
    dynamodb_table = "terraform_state_lock"
  }
}
