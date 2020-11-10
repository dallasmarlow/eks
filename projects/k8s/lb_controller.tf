resource "kubernetes_manifest" "lb_controller_service_account" {
	provider = kubernetes-alpha
	manifest = {
		apiVersion = "v1"
		kind = "ServiceAccount"
		metadata = {
			annotations = {
				"eks.amazonaws.com/role-arn" = data.terraform_remote_state.eks_cluster.outputs.aws_lb_controller_role_arn
			}
			labels = {
				"app.kubernetes.io/component" = "controller"
				"app.kubernetes.io/name" = "aws-load-balancer-controller"
			}
			name = "aws-load-balancer-controller"
			namespace = "kube-system"
		}
	}
}