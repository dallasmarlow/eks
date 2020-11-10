# https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/v1.7.5/config/v1.7/aws-k8s-cni.yaml

# due to the issues listed below the terraform kubernetes-alpha provider is not able to create the required
# `ClusterRole` and `DaemonSet` manifests. Until these issues are resolved these manifests will be created
# using kubectl via the normal terraform kubernetes provider.

# `ClusterRole` manifest fails to apply due to rule update conflicts resulting in the following error:

# Error: rpc error: code = Unknown desc = update dry-run for '/aws-node' failed: Apply failed with 1 conflict: conflict with "kubectl" using rbac.authorization.k8s.io/v1: .rules

# `DaemonSet` manifest fails to apply due to undefined port protocol in spec. see https://github.com/aws/amazon-vpc-cni-k8s/pull/1284
# `DaemonSet` manifest fails to apply due to update conflicts (see https://github.com/kubernetes/kubernetes/issues/80916) resulting in the following errors:

# Error: rpc error: code = Unknown desc = update dry-run for 'kube-system/aws-node' failed: Apply failed with 3 conflicts: conflicts with "kubectl" using apps/v1:
# - .spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms
# - .spec.template.spec.containers[name="aws-node"].image
# - .spec.template.spec.initContainers[name="aws-vpc-cni-init"].image

# https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/v1.7.5/config/v1.7/aws-k8s-cni.yaml

resource "kubectl_manifest" "cni_eni_cfg_crd" {
	yaml_body = file("${path.module}/manifests/aws-k8s-cni/eni-cfg-crd.yaml")
}

resource "kubernetes_manifest" "cni_pod_network_a_eni_cfg_crd" {
	provider = kubernetes-alpha
	manifest = {
		apiVersion = "crd.k8s.amazonaws.com/v1alpha1"
		kind = "ENIConfig"
		metadata = {
			name = "${var.region}a"
		}
		spec = {
			subnet = data.terraform_remote_state.vpc.outputs.eks_test_pod_subnet_a
			securityGroups = [
				data.terraform_remote_state.eks_compute.outputs.eks_compute_sg,
			]
		}
	}
	depends_on = [
		kubectl_manifest.cni_eni_cfg_crd,
	]
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
			subnet = data.terraform_remote_state.vpc.outputs.eks_test_pod_subnet_b
			securityGroups = [
				data.terraform_remote_state.eks_compute.outputs.eks_compute_sg,
			]
		}
	}
	depends_on = [
		kubectl_manifest.cni_eni_cfg_crd,
	]
}

resource "kubectl_manifest" "cni_service_account" {
	yaml_body = file("${path.module}/manifests/aws-k8s-cni/service-account.yaml")
}

resource "kubectl_manifest" "cni_cluster_role" {
	yaml_body = file("${path.module}/manifests/aws-k8s-cni/cluster-role.yaml")
	depends_on = [
		kubectl_manifest.cni_eni_cfg_crd,
	]
}

resource "kubectl_manifest" "cni_cluster_role_binding" {
	yaml_body = file("${path.module}/manifests/aws-k8s-cni/cluster-role-binding.yaml")
	depends_on = [
		kubectl_manifest.cni_cluster_role,
		kubectl_manifest.cni_service_account,
	]
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
		kubectl_manifest.cni_cluster_role_binding,
	]
}

# resource "kubernetes_manifest" "cni_cluster_role_binding" {
# 	provider = kubernetes-alpha
# 	manifest = {
# 		apiVersion = "rbac.authorization.k8s.io/v1"
# 		kind = "ClusterRoleBinding"
# 		metadata = {
# 			name = "aws-node"
# 		}
# 		roleRef = {
# 			apiGroup = "rbac.authorization.k8s.io"
# 			kind = "ClusterRole"
# 			name = "aws-node"
# 		}
# 		subjects = [
# 			{
# 				kind = "ServiceAccount"
# 				name = "aws-node"
# 				namespace = "kube-system"
# 			}
# 		]
# 	}
# }

# resource "kubernetes_manifest" "cni_cluster_role" {
# 	provider = kubernetes-alpha
# 	manifest = {
# 		apiVersion = "rbac.authorization.k8s.io/v1"
# 		kind = "ClusterRole"
# 		metadata = {
# 			name = "aws-node"
# 		}
# 		rules = [
# 			{
# 				apiGroups = [
# 					"crd.k8s.amazonaws.com",
# 				]
# 				resources = [
# 					"eniconfigs",
# 				]
# 				verbs = [
# 					"get",
# 					"list",
# 					"watch",
# 				]
# 			},
# 			{
# 				apiGroups = [""],
# 				resources = [
# 					"pods",
# 					"namespaces",
# 				]
# 				verbs = [
# 					"get",
# 					"list",
# 					"watch",
# 				]
# 			},
# 			{
# 				apiGroups = [""],
# 				resources = [
# 					"nodes",
# 				]
# 				verbs = [
# 					"get",
# 					"list",
# 					"update",
# 					"watch",
# 				]
# 			},
# 			{
# 				apiGroups = [
# 					"extensions",
# 				]
# 				resources = [
# 					"*",
# 				]
# 				verbs = [
# 					"list",
# 					"watch",
# 				]
# 			}
# 		]
# 	}
# }

# resource "kubernetes_manifest" "cni_crd" {
# 	provider = kubernetes-alpha
# 	manifest = {
# 		apiVersion = "apiextensions.k8s.io/v1beta1"
# 		kind = "CustomResourceDefinition"
# 		metadata = {
# 			name = "eniconfigs.crd.k8s.amazonaws.com"
# 		}
# 		spec = {
# 			group = "crd.k8s.amazonaws.com"
# 			names = {
# 				kind = "ENIConfig"
# 				plural = "eniconfigs"
# 				singular = "eniconfig"
# 			}
# 			scope = "Cluster"
# 			versions = [
# 				{
# 					name = "v1alpha1"
# 					served = true
# 					storage = true
# 				}
# 			]
# 		}
# 	}
# }

# resource "kubernetes_manifest" "cni_daemon_set" {
# 	provider = kubernetes-alpha
# 	manifest = {
# 		"apiVersion" = "apps/v1"
# 		"kind" = "DaemonSet"
# 		"metadata" = {
# 			"labels" = {
# 				"k8s-app" = "aws-node"
# 			}
# 			"name" = "aws-node"
# 			"namespace" = "kube-system"
# 		}
# 		"spec" = {
# 			"selector" = {
# 				"matchLabels" = {
# 					"k8s-app" = "aws-node"
# 				}
# 			}
# 			"template" = {
# 				"metadata" = {
# 					"labels" = {
# 						"k8s-app" = "aws-node"
# 					}
# 				}
# 				"spec" = {
# 					"affinity" = {
# 						"nodeAffinity" = {
# 							"requiredDuringSchedulingIgnoredDuringExecution" = {
# 								"nodeSelectorTerms" = [
# 								{
# 									"matchExpressions" = [
# 									{
# 										"key" = "beta.kubernetes.io/os"
# 										"operator" = "In"
# 										"values" = [
# 										"linux",
# 										]
# 									},
# 									{
# 										"key" = "beta.kubernetes.io/arch"
# 										"operator" = "In"
# 										"values" = [
# 										"amd64",
# 										"arm64",
# 										]
# 									},
# 									{
# 										"key" = "eks.amazonaws.com/compute-type"
# 										"operator" = "NotIn"
# 										"values" = [
# 										"fargate",
# 										]
# 									},
# 									]
# 								},
# 								{
# 									"matchExpressions" = [
# 									{
# 										"key" = "kubernetes.io/os"
# 										"operator" = "In"
# 										"values" = [
# 										"linux",
# 										]
# 									},
# 									{
# 										"key" = "kubernetes.io/arch"
# 										"operator" = "In"
# 										"values" = [
# 										"amd64",
# 										"arm64",
# 										]
# 									},
# 									{
# 										"key" = "eks.amazonaws.com/compute-type"
# 										"operator" = "NotIn"
# 										"values" = [
# 										"fargate",
# 										]
# 									},
# 									]
# 								},
# 								]
# 							}
# 						}
# 					}
# 					"containers" = [
# 					{
# 						"env" = [
# 						{
# 							"name" = "ADDITIONAL_ENI_TAGS"
# 							"value" = "{}"
# 						},
# 						{
# 							"name" = "AWS_VPC_CNI_NODE_PORT_SUPPORT"
# 							"value" = "true"
# 						},
# 						{
# 							"name" = "AWS_VPC_ENI_MTU"
# 							"value" = "9001"
# 						},
# 						{
# 							"name" = "AWS_VPC_K8S_CNI_CONFIGURE_RPFILTER"
# 							"value" = "false"
# 						},
# 						{
# 							"name" = "AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG"
# 							"value" = "false"
# 						},
# 						{
# 							"name" = "AWS_VPC_K8S_CNI_EXTERNALSNAT"
# 							"value" = "false"
# 						},
# 						{
# 							"name" = "AWS_VPC_K8S_CNI_LOGLEVEL"
# 							"value" = "DEBUG"
# 						},
# 						{
# 							"name" = "AWS_VPC_K8S_CNI_LOG_FILE"
# 							"value" = "/host/var/log/aws-routed-eni/ipamd.log"
# 						},
# 						{
# 							"name" = "AWS_VPC_K8S_CNI_RANDOMIZESNAT"
# 							"value" = "prng"
# 						},
# 						{
# 							"name" = "AWS_VPC_K8S_CNI_VETHPREFIX"
# 							"value" = "eni"
# 						},
# 						{
# 							"name" = "AWS_VPC_K8S_PLUGIN_LOG_FILE"
# 							"value" = "/var/log/aws-routed-eni/plugin.log"
# 						},
# 						{
# 							"name" = "AWS_VPC_K8S_PLUGIN_LOG_LEVEL"
# 							"value" = "DEBUG"
# 						},
# 						{
# 							"name" = "DISABLE_INTROSPECTION"
# 							"value" = "false"
# 						},
# 						{
# 							"name" = "DISABLE_METRICS"
# 							"value" = "false"
# 						},
# 						{
# 							"name" = "ENABLE_POD_ENI"
# 							"value" = "false"
# 						},
# 						{
# 							"name" = "MY_NODE_NAME"
# 							"valueFrom" = {
# 								"fieldRef" = {
# 									"fieldPath" = "spec.nodeName"
# 								}
# 							}
# 						},
# 						{
# 							"name" = "WARM_ENI_TARGET"
# 							"value" = "1"
# 						},
# 						]
# 						"image" = var.cni_docker_img
# 						"imagePullPolicy" = "Always"
# 						"livenessProbe" = {
# 							"exec" = {
# 								"command" = [
# 								"/app/grpc-health-probe",
# 								"-addr=:50051",
# 								]
# 							}
# 							"initialDelaySeconds" = 60
# 						}
# 						"name" = "aws-node"
# 						"ports" = [
# 						{
# 							"containerPort" = 61678
# 							"name" = "metrics"
# 							"protocol" = "tcp"
# 						},
# 						]
# 						"readinessProbe" = {
# 							"exec" = {
# 								"command" = [
# 								"/app/grpc-health-probe",
# 								"-addr=:50051",
# 								]
# 							}
# 							"initialDelaySeconds" = 1
# 						}
# 						"resources" = {
# 							"requests" = {
# 								"cpu" = "10m"
# 							}
# 						}
# 						"securityContext" = {
# 							"capabilities" = {
# 								"add" = [
# 								"NET_ADMIN",
# 								]
# 							}
# 						}
# 						"volumeMounts" = [
# 						{
# 							"mountPath" = "/host/opt/cni/bin"
# 							"name" = "cni-bin-dir"
# 						},
# 						{
# 							"mountPath" = "/host/etc/cni/net.d"
# 							"name" = "cni-net-dir"
# 						},
# 						{
# 							"mountPath" = "/host/var/log/aws-routed-eni"
# 							"name" = "log-dir"
# 						},
# 						{
# 							"mountPath" = "/var/run/aws-node"
# 							"name" = "run-dir"
# 						},
# 						{
# 							"mountPath" = "/var/run/dockershim.sock"
# 							"name" = "dockershim"
# 						},
# 						{
# 							"mountPath" = "/run/xtables.lock"
# 							"name" = "xtables-lock"
# 						},
# 						]
# 					},
# 					]
# 					"hostNetwork" = true
# 					"initContainers" = [
# 					{
# 						"env" = [
# 						{
# 							"name" = "DISABLE_TCP_EARLY_DEMUX"
# 							"value" = "false"
# 						},
# 						]
# 						"image" = var.cni_init_docker_img
# 						"imagePullPolicy" = "Always"
# 						"name" = "aws-vpc-cni-init"
# 						"securityContext" = {
# 							"privileged" = true
# 						}
# 						"volumeMounts" = [
# 						{
# 							"mountPath" = "/host/opt/cni/bin"
# 							"name" = "cni-bin-dir"
# 						},
# 						]
# 					},
# 					]
# 					"priorityClassName" = "system-node-critical"
# 					"serviceAccountName" = "aws-node"
# 					"terminationGracePeriodSeconds" = 10
# 					"tolerations" = [
# 					{
# 						"operator" = "Exists"
# 					},
# 					]
# 					"volumes" = [
# 					{
# 						"hostPath" = {
# 							"path" = "/opt/cni/bin"
# 						}
# 						"name" = "cni-bin-dir"
# 					},
# 					{
# 						"hostPath" = {
# 							"path" = "/etc/cni/net.d"
# 						}
# 						"name" = "cni-net-dir"
# 					},
# 					{
# 						"hostPath" = {
# 							"path" = "/var/run/dockershim.sock"
# 						}
# 						"name" = "dockershim"
# 					},
# 					{
# 						"hostPath" = {
# 							"path" = "/run/xtables.lock"
# 						}
# 						"name" = "xtables-lock"
# 					},
# 					{
# 						"hostPath" = {
# 							"path" = "/var/log/aws-routed-eni"
# 							"type" = "DirectoryOrCreate"
# 						}
# 						"name" = "log-dir"
# 					},
# 					{
# 						"hostPath" = {
# 							"path" = "/var/run/aws-node"
# 							"type" = "DirectoryOrCreate"
# 						}
# 						"name" = "run-dir"
# 					},
# 					]
# 				}
# 			}
# 			"updateStrategy" = {
# 				"rollingUpdate" = {
# 					"maxUnavailable" = "10%"
# 				}
# 				"type" = "RollingUpdate"
# 			}
# 		}
# 	  }
#   }