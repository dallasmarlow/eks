resource "aws_ecr_repository" "eks_test" {
	name = "eks_test"
	encryption_configuration {
		encryption_type = "AES256"
	}
	tags = {
		Name = "eks_test"
	}
}