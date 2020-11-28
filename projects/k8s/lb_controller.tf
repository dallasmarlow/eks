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
				"app.kubernetes.io/name" = var.lb_controller_service_account_name
			}
			name = var.lb_controller_service_account_name
			namespace = "kube-system"
		}
	}
}

resource "helm_release" "lb_controller" {
	chart = "aws-load-balancer-controller"
	name = "aws-load-balancer-controller"
	namespace = "kube-system"
	repository = "https://aws.github.io/eks-charts/"
	version = var.lb_controller_chart_version
	wait = false # this chart always timesouts when deployed
	set {
		name = "clusterName"
		value = data.terraform_remote_state.eks_cluster.outputs.eks_cluster_name
	}
	set {
		name = "region"
		value = var.region
	}
	set {
		name = "serviceAccount.create"
		value = "false"
	}
	set {
		name = "serviceAccount.name"
		value = var.lb_controller_service_account_name
	}
	set {
		name = "vpcId"
		value = data.terraform_remote_state.vpc.outputs.eks_test_vpc_id
	}
	depends_on = [
		kubernetes_manifest.lb_controller_service_account,
	]
}