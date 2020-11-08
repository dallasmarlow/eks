output "ec2_instance_connect_policy_arn" {
	value = aws_iam_policy.ec2_instance_connect.arn
}

output "eks_test_ec2_keypair_name" {
	value = aws_key_pair.eks_test.key_name
}