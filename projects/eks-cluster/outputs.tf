output "eks_cluster_endpoint" {
	value = aws_eks_cluster.eks_cluster.endpoint
}

output "eks_cluster_sg_id" {
	value = aws_security_group.eks_cluster.id
}

output "eks_cluster_version" {
	value = aws_eks_cluster.eks_cluster.version
}