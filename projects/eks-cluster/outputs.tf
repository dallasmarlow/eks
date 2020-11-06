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
