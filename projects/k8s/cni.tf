# https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/v1.7.5/config/v1.7/aws-k8s-cni.yaml

# The latest EKS AMI now (11/20/11) includes version 1.7.5 of the CNI plugin pre-installed which means
# terraform only needs to create the per-AZ ENIConfig CRDs and the daemonset manifests.

# The daemonset manifest / template parameters will need to be updated as EKS AMIs change to
# different versions of the CNI plugin over time.

resource "kubernetes_manifest" "cni_pod_network_a_eni_cfg_crd" {
	provider = kubernetes-alpha
	manifest = {
		apiVersion = "crd.k8s.amazonaws.com/v1alpha1"
		kind = "ENIConfig"
		metadata = {
			name = "${var.region}a"
		}
		spec = {
			subnet = data.terraform_remote_state.vpc.outputs.pod_subnet_ids[0]
			securityGroups = [
				data.terraform_remote_state.eks_compute.outputs.sg,
			]
		}
	}
}

resource "kubernetes_manifest" "cni_pod_network_b_eni_cfg_crd" {
	provider = kubernetes-alpha
	manifest = {
		apiVersion = "crd.k8s.amazonaws.com/v1alpha1"
		kind = "ENIConfig"
		metadata = {
			name = "${var.region}b"
		}
		spec = {
			subnet = data.terraform_remote_state.vpc.outputs.pod_subnet_ids[1]
			securityGroups = [
				data.terraform_remote_state.eks_compute.outputs.sg,
			]
		}
	}
}

resource "kubectl_manifest" "cni_daemonset" {
	yaml_body = templatefile(
		"${path.module}/manifests/aws-k8s-cni/daemonset.yaml.tpl",
		{
			CUSTOM_NETWORK_CFG = var.cni_custom_network_cfg,
			DOCKER_IMG = var.cni_docker_img,
			ENI_CONFIG_LABEL = var.cni_eni_config_label,
			INIT_DOCKER_IMG = var.cni_init_docker_img,
		}
	)
	depends_on = [
		kubernetes_manifest.cni_pod_network_a_eni_cfg_crd,
		kubernetes_manifest.cni_pod_network_b_eni_cfg_crd,
	]
}