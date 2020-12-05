output "aws_lb_controller_role_arn" {
	value = aws_iam_role.aws_lb_controller.arn
}

output "eks_cluster_ca" {
	value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "eks_cluster_endpoint" {
	value = aws_eks_cluster.eks_cluster.endpoint
}

output "eks_cluster_name" {
	value = aws_eks_cluster.eks_cluster.name
}

output "eks_cluster_sg_id" {
	value = aws_security_group.eks_cluster.id
}

output "eks_cluster_version" {
	value = aws_eks_cluster.eks_cluster.version
}

output "s3_bucket_helm_repo" {
	value = aws_s3_bucket.helm_repo.id
}

output "s3_bucket_lb_logs" {
	value = aws_s3_bucket.lb_logs.id
}