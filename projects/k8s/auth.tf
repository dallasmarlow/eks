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
				rolearn = data.terraform_remote_state.eks.outputs.eks_worker_role_arn
				username = "system:node:{{EC2PrivateDNSName}}"
				groups = [
					"system:bootstrappers",
					"system:nodes",
				]
			}
		])
	}
}