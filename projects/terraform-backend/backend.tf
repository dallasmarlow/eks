terraform {
  backend "s3" {
    bucket         = "eks-test-tf-backend"
    region         = "us-east-2"
    key            = "terraform-backend/terraform.tfstate"
    dynamodb_table = "terraform_state_lock"
  }
}
