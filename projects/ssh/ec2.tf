resource "aws_key_pair" "primary" {
  key_name_prefix = "${var.eks_cluster_name}-"
  public_key      = tls_private_key.primary.public_key_openssh
}