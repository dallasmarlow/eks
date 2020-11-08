resource "aws_key_pair" "eks_test" {
	key_name_prefix = "${var.eks_cluster_name}-"
	public_key = tls_private_key.eks_test.public_key_openssh 
}