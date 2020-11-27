resource "kubernetes_config_map" "aws_auth" {
	metadata {
		name = "aws-auth"
		namespace = "kube-system"
	}
	data = {
		mapRoles = yamlencode([
			{
				rolearn = data.terraform_remote_state.bastion.outputs.bastion_role_arn
				username = "bastion"
				groups = ["system:masters"]
			},
			{
				rolearn = data.terraform_remote_state.eks_compute.outputs.eks_compute_role_arn
				username = "system:node:{{EC2PrivateDNSName}}"
				groups = [
					"system:bootstrappers",
					"system:nodes",
				]
			}
		])
	}
}

resource "kubernetes_manifest" "eks_admin_service_account" {
  provider = kubernetes-alpha
  manifest = {
    apiVersion = "v1"
    kind = "ServiceAccount"
    metadata = {
      name = "eks-admin"
      namespace = "kube-system"
    }
  }
}

resource "kubernetes_manifest" "eks_admin_cluster_role_binding" {
  provider = kubernetes-alpha
  manifest = {
    apiVersion = "rbac.authorization.k8s.io/v1"
    kind = "ClusterRoleBinding"
    metadata = {
      name = "eks-admin"
    }
    roleRef = {
      apiGroup = "rbac.authorization.k8s.io"
      kind = "ClusterRole"
      name = "cluster-admin"
    }
    subjects = [
      {
        kind = "ServiceAccount"
        name = "eks-admin"
        namespace = "kube-system"
      },
    ]
  }
  depends_on = [
    kubernetes_manifest.eks_admin_service_account,
  ]
}