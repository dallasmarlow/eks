resource "aws_cloudwatch_log_group" "eks_cluster" {
	name = "/aws/eks/${var.eks_cluster_name}/cluster"
	retention_in_days = 1
}

resource "aws_eks_cluster" "eks_cluster" {
	name = var.eks_cluster_name
	enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
	encryption_config {
		provider {
			key_arn = aws_kms_key.eks_cluster.arn
		}
		resources = ["secrets"]
	}
	role_arn = aws_iam_role.eks_cluster.arn
	version = var.eks_version
	vpc_config {
		endpoint_private_access = true
		endpoint_public_access = false
		security_group_ids = [aws_security_group.eks_cluster.id]
		subnet_ids = [
			data.terraform_remote_state.vpc.outputs.eks_test_priv_subnet_a,
			data.terraform_remote_state.vpc.outputs.eks_test_priv_subnet_b,
		]
	}
	depends_on = [
		aws_cloudwatch_log_group.eks_cluster,
		aws_iam_role_policy_attachment.eks_cluster,
	]
}

resource "aws_iam_openid_connect_provider" "eks_cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = []
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}