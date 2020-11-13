# APIService manifest generates the following error when using the terraform
# kubernetes-alpha provider: 

# Error: rpc error: code = Unknown desc = update dry-run for '/v1beta1.metrics.k8s.io' failed: Patch "https://CA4772A5B82FD0A410CFFEC53AC9CE04.gr7.us-east-2.eks.amazonaws.com/apis/apiregistration.k8s.io/v1beta1/apiservices/v1beta1.metrics.k8s.io?dryRun=All&fieldManager=Terraform": stream error: stream ID 93; INTERNAL_ERROR

# resource "kubernetes_manifest" "metrics_server_api_service" {
# 	provider = kubernetes-alpha
# 	manifest = {
# 		apiVersion = "apiregistration.k8s.io/v1beta1"
# 		kind = "APIService"
# 		metadata = {
# 			name = "v1beta1.metrics.k8s.io"
# 		}
# 		spec = {
# 			service = {
# 				name = "metrics-server"
# 				namespace = "kube-system"
# 			}
# 			group = "metrics.k8s.io"
# 			version = "v1beta1"
# 			insecureSkipTLSVerify = true
# 			groupPriorityMinimum = 100
# 			versionPriority = 100
# 		}
# 	}

# Service manifest generates the following error when using the terraform
# kubernetes-alpha provider:

# Error: Provider produced inconsistent result after apply

# When applying changes to kubernetes_manifest.metrics_server_service, provider
# "registry.terraform.io/hashicorp/kubernetes-alpha" produced an unexpected new
# value: .object: wrong final value type: attribute "apiVersion": string
# required.

# This is a bug in the provider, which should be reported in the provider's own
# issue tracker.

# resource "kubernetes_manifest" "metrics_server_service" {
# 	provider = kubernetes-alpha
# 	manifest = {
# 		apiVersion = "v1"
# 		kind = "Service"
# 		metadata = {
# 			labels = {
# 				"kubernetes.io/name": "Metrics-server"
# 				"kubernetes.io/cluster-service": "true"
# 			}
# 			name = "metrics-server"
# 			namespace = "kube-system"
# 		}
# 		spec = {
# 			ports = [
# 				{
# 					port = 443
# 					protocol = "TCP"
# 					targetPort = "main-port"
# 				},
# 			]
# 			selector = {
# 				"k8s-app": "metrics-server"
# 			}
# 		}
# 	}
# }

resource "kubectl_manifest" "metrics_server_api_service" {
	yaml_body = file("${path.module}/manifests/metrics-server/api_service_0_3_7.yaml")
}

resource "kubectl_manifest" "metrics_server_service" {
	yaml_body = file("${path.module}/manifests/metrics-server/service_0_3_7.yaml")
}

resource "kubernetes_manifest" "metrics_server_service_account" {
	provider = kubernetes-alpha
	manifest = {
		apiVersion = "v1"
		kind = "ServiceAccount"
		metadata = {
			name = "metrics-server"
			namespace = "kube-system"
		}
	}
}

resource "kubernetes_manifest" "metrics_server_cluster_role" {
	provider = kubernetes-alpha
	manifest = {
		apiVersion = "rbac.authorization.k8s.io/v1"
		kind = "ClusterRole"
		metadata = {
			name = "system:metrics-server"
		}
		rules = [
			{
				apiGroups = [
					"",
				]
				resources = [
					"pods",
					"nodes",
					"nodes/stats",
					"namespaces",
					"configmaps",
				]
				verbs = [
					"get",
					"list",
					"watch",
				]
			},
		]
	}
}

resource "kubernetes_manifest" "metrics_server_cluster_role_metrics_reader" {
	provider = kubernetes-alpha
	manifest = {
		apiVersion = "rbac.authorization.k8s.io/v1"
		kind = "ClusterRole"
		metadata = {
			labels = {
				"k8s-app": "metrics-server"
				"rbac.authorization.k8s.io/aggregate-to-admin": "true"
				"rbac.authorization.k8s.io/aggregate-to-edit": "true"
				"rbac.authorization.k8s.io/aggregate-to-view": "true"
			}
			name = "system:aggregated-metrics-reader"
		}
		rules = [
			{
				apiGroups = [
					"metrics.k8s.io",
				]
				resources = [
					"pods",
					"nodes",
				]
				verbs = [
					"get",
					"list",
					"watch",
				]
			},
		]
	}
}

resource "kubernetes_manifest" "metrics_server_role_binding_auth_reader" {
	provider = kubernetes-alpha
	manifest = {
		apiVersion = "rbac.authorization.k8s.io/v1"
		kind = "RoleBinding"
		metadata = {
			name = "metrics-server-auth-reader"
			namespace = "kube-system"
		}
		roleRef = {
			apiGroup = "rbac.authorization.k8s.io"
			kind = "Role"
			name = "extension-apiserver-authentication-reader"
		}
		subjects = [
			{
				kind = "ServiceAccount"
				name = "metrics-server"
				namespace = "kube-system"
			},
		]
	}
	depends_on = [
		kubernetes_manifest.metrics_server_service_account,
	]
}

resource "kubernetes_manifest" "metrics_server_cluster_role_binding" {
	provider = kubernetes-alpha
	manifest = {
		apiVersion = "rbac.authorization.k8s.io/v1"
		kind = "ClusterRoleBinding"
		metadata = {
			name = "system:metrics-server"
		}
		roleRef = {
			apiGroup = "rbac.authorization.k8s.io"
			kind = "ClusterRole"
			name = "system:metrics-server"
		}
		subjects = [
			{
				kind = "ServiceAccount"
				name = "metrics-server"
				namespace = "kube-system"
			},
		]
	}
	depends_on = [
		kubernetes_manifest.metrics_server_cluster_role,
		kubernetes_manifest.metrics_server_service_account,
	]
}

resource "kubernetes_manifest" "metrics_server_cluster_role_binding_auth_delegator" {
	provider = kubernetes-alpha
	manifest = {
		apiVersion = "rbac.authorization.k8s.io/v1"
		kind = "ClusterRoleBinding"
		metadata = {
			name = "metrics-server:system:auth-delegator"
		}
		roleRef = {
			apiGroup = "rbac.authorization.k8s.io"
			kind = "ClusterRole"
			name = "system:auth-delegator"
		}
		subjects = [
			{
				kind = "ServiceAccount"
				name = "metrics-server"
				namespace = "kube-system"
			},
		]
	}
	depends_on = [
		kubernetes_manifest.metrics_server_service_account,
	]
}

resource "kubernetes_manifest" "metrics_server_deployment" {
	provider = kubernetes-alpha
	manifest = {
		apiVersion = "apps/v1"
		kind = "Deployment"
		metadata = {
			labels = {
				"k8s-app": "metrics-server"
			}
			name = "metrics-server"
			namespace = "kube-system"			
		}
		spec = {
			selector = {
				matchLabels = {
					"k8s-app": "metrics-server"
				}
			}
			template = {
				metadata = {
					name: "metrics-server"
					labels = {
						"k8s-app" = "metrics-server"
					}
				}
				spec = {
					containers = [
						{
							args = [
								"--cert-dir=/tmp",
								"--secure-port=4443",
							]
							image = var.metrics_server_docker_img
							imagePullPolicy = "IfNotPresent"
							name = "metrics-server"
							ports = [
								{
									containerPort = 4443
									name = "main-port"
									protocol = "TCP"
								},
							]
							securityContext = {
								readOnlyRootFilesystem = true
								runAsNonRoot = true
								runAsUser = 1000
							}
							volumeMounts = [
								{
									mountPath = "/tmp"
									name = "tmp-dir"
								},
							]
						},
					]
					nodeSelector = {
						"kubernetes.io/os" = "linux"
					}
					serviceAccountName = "metrics-server"
					volumes = [
						{
							emptyDir = {}
							name = "tmp-dir"
						},
					]
				}
			}
		}
	}
	depends_on = [
		kubernetes_manifest.metrics_server_service_account,
	]
}
