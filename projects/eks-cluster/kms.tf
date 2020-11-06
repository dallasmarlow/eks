resource "aws_kms_key" "eks_cluster" {
	description = "KMS key to be used with EKS cluster."
}