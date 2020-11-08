resource "aws_kms_key" "eks_compute_ebs" {
	description = "KMS key to be used with EKS compute EBS volumes."
}

resource "aws_kms_grant" "eks_compute_ebs_asg" {
	name = "${var.eks_cluster_name}-eks-compute-ebs-asg"
	key_id = aws_kms_key.eks_compute_ebs.arn
	grantee_principal = "arn:aws:iam::${var.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
	operations = [
		"Encrypt",
		"Decrypt",
		"ReEncryptFrom",
		"ReEncryptTo",
		"GenerateDataKey",
		"GenerateDataKeyWithoutPlaintext",
		"DescribeKey",
		"CreateGrant",
	]
	# the `AWSServiceRoleForAutoScaling` role is created after the first ASG is created within an AWS account
	depends_on = [
		aws_autoscaling_group.eks_compute,
	]
}
