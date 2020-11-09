output "eks_compute_role_arn" {
	value = aws_iam_role.eks_compute.arn
}

output "eks_compute_asg_name" {
	value = aws_autoscaling_group.eks_compute.name
}

output "eks_compute_sg" {
	value = aws_security_group.eks_compute.id
}