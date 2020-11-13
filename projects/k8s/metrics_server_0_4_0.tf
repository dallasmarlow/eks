# https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.4.0/components.yaml

# The metrics server service manifest can not be created with terraform
# kubernetes-alpha due to a bug:

# Error: Provider produced inconsistent result after apply

# When applying changes to kubernetes_manifest.metrics_server_service, provider
# "registry.terraform.io/hashicorp/kubernetes-alpha" produced an unexpected new
# value: .object: wrong final value type: attribute "kind": string required.

# This is a bug in the provider, which should be reported in the provider's own
# issue tracker. 

# resource "kubernetes_manifest" "metrics_server_service_account" {
# 	provider = kubernetes-alpha
# 	manifest = {
# 		apiVersion = "v1"
# 		kind = "ServiceAccount"
# 		metadata = {
# 			labels = {
# 				"k8s-app": "metrics-server"
# 			}
# 			name = "metrics-server"
# 			namespace = "kube-system"
# 		}
# 	}
# }

# resource "kubernetes_manifest" "metrics_server_cluster_role" {
# 	provider = kubernetes-alpha
# 	manifest = {
# 		apiVersion = "rbac.authorization.k8s.io/v1"
# 		kind = "ClusterRole"
# 		metadata = {
# 			labels = {
# 				"k8s-app": "metrics-server"
# 			}
# 			name = "system:metrics-server"
# 		}
# 		rules = [
# 			{
# 				apiGroups = [
# 					"",
# 				]
# 				resources = [
# 					"pods",
# 					"nodes",
# 					"nodes/stats",
# 					"namespaces",
# 					"configmaps",
# 				]
# 				verbs = [
# 					"get",
# 					"list",
# 					"watch",
# 				]
# 			},
# 		]
# 	}
# }

# resource "kubernetes_manifest" "metrics_server_cluster_role_metrics_reader" {
# 	provider = kubernetes-alpha
# 	manifest = {
# 		apiVersion = "rbac.authorization.k8s.io/v1"
# 		kind = "ClusterRole"
# 		metadata = {
# 			labels = {
# 				"k8s-app": "metrics-server"
# 				"rbac.authorization.k8s.io/aggregate-to-admin": "true"
# 				"rbac.authorization.k8s.io/aggregate-to-edit": "true"
# 				"rbac.authorization.k8s.io/aggregate-to-view": "true"
# 			}
# 			name = "system:aggregated-metrics-reader"
# 		}
# 		rules = [
# 			{
# 				apiGroups = [
# 					"metrics.k8s.io",
# 				]
# 				resources = [
# 					"pods",
# 					"nodes",
# 				]
# 				verbs = [
# 					"get",
# 					"list",
# 					"watch",
# 				]
# 			},
# 		]
# 	}
# }

# resource "kubernetes_manifest" "metrics_server_role_binding_auth_reader" {
# 	provider = kubernetes-alpha
# 	manifest = {
# 		apiVersion = "rbac.authorization.k8s.io/v1"
# 		kind = "RoleBinding"
# 		metadata = {
# 			labels = {
# 				"k8s-app": "metrics-server"
# 			}
# 			name = "metrics-server-auth-reader"
# 			namespace = "kube-system"
# 		}
# 		roleRef = {
# 			apiGroup = "rbac.authorization.k8s.io"
# 			kind = "Role"
# 			name = "extension-apiserver-authentication-reader"
# 		}
# 		subjects = [
# 			{
# 				kind = "ServiceAccount"
# 				name = "metrics-server"
# 				namespace = "kube-system"
# 			},
# 		]
# 	}
# 	depends_on = [
# 		kubernetes_manifest.metrics_server_service_account,
# 	]
# }

# resource "kubernetes_manifest" "metrics_server_cluster_role_binding" {
# 	provider = kubernetes-alpha
# 	manifest = {
# 		apiVersion = "rbac.authorization.k8s.io/v1"
# 		kind = "ClusterRoleBinding"
# 		metadata = {
# 			labels = {
# 				"k8s-app": "metrics-server"
# 			}
# 			name = "system:metrics-server"
# 		}
# 		roleRef = {
# 			apiGroup = "rbac.authorization.k8s.io"
# 			kind = "ClusterRole"
# 			name = "system:metrics-server"
# 		}
# 		subjects = [
# 			{
# 				kind = "ServiceAccount"
# 				name = "metrics-server"
# 				namespace = "kube-system"
# 			},
# 		]
# 	}
# 	depends_on = [
# 		kubernetes_manifest.metrics_server_cluster_role,
# 		kubernetes_manifest.metrics_server_service_account,
# 	]
# }

# resource "kubernetes_manifest" "metrics_server_cluster_role_binding_auth_delegator" {
# 	provider = kubernetes-alpha
# 	manifest = {
# 		apiVersion = "rbac.authorization.k8s.io/v1"
# 		kind = "ClusterRoleBinding"
# 		metadata = {
# 			labels = {
# 				"k8s-app": "metrics-server"
# 			}
# 			name = "metrics-server:system:auth-delegator"
# 		}
# 		roleRef = {
# 			apiGroup = "rbac.authorization.k8s.io"
# 			kind = "ClusterRole"
# 			name = "system:auth-delegator"
# 		}
# 		subjects = [
# 			{
# 				kind = "ServiceAccount"
# 				name = "metrics-server"
# 				namespace = "kube-system"
# 			},
# 		]
# 	}
# 	depends_on = [
# 		kubernetes_manifest.metrics_server_service_account,
# 	]
# }

# resource "kubectl_manifest" "metrics_server_service" {
# 	yaml_body = file("${path.module}/manifests/metrics-server/service_0_4_0.yaml")
# }

# resource "kubernetes_manifest" "metrics_server_service" {
# 	provider = kubernetes-alpha
# 	manifest = {
# 		apiVersion = "v1"
# 		kind = "Service"
# 		metadata = {
# 			labels = {
# 				"k8s-app": "metrics-server"
# 			}
# 			name = "metrics-server"
# 			namespace = "kube-system"
# 		}
# 		spec = {
# 			ports = [
# 				{
# 					name = "https"
# 					port = 443
# 					protocol = "TCP"
# 					targetPort = "https"
# 				},
# 			]
# 			selector = {
# 				"k8s-app": "metrics-server"
# 			}
# 		}
# 	}
# }

# resource "kubernetes_manifest" "metrics_server_deployment" {
# 	provider = kubernetes-alpha
# 	manifest = {
# 		apiVersion = "apps/v1"
# 		kind = "Deployment"
# 		metadata = {
# 			labels = {
# 				"k8s-app": "metrics-server"
# 			}
# 			name = "metrics-server"
# 			namespace = "kube-system"			
# 		}
# 		spec = {
# 			selector = {
# 				matchLabels = {
# 					"k8s-app": "metrics-server"
# 				}
# 			}
# 			strategy = {
# 				rollingUpdate = {
# 					maxUnavailable = 0
# 				}
# 			}
# 			template = {
# 				metadata = {
# 					labels = {
# 						"k8s-app" = "metrics-server"
# 					}
# 				}
# 				spec = {
# 					containers = [
# 						{
# 							args = [
# 								"--cert-dir=/tmp",
# 								"--secure-port=4443",
# 								"--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname",
# 								"--kubelet-use-node-status-port",
# 							]
# 							image = var.metrics_server_docker_img
# 							imagePullPolicy = "IfNotPresent"
# 							livenessProbe = {
# 								failureThreshold = 3
# 								httpGet = {
# 									path = "/livez"
# 									port = "https"
# 									scheme = "HTTPS"
# 								}
# 								periodSeconds = 10
# 							}
# 							name = "metrics-server"
# 							ports = [
# 								{
# 									containerPort = 4443
# 									name = "https"
# 									protocol = "TCP"
# 								},
# 							]
# 							readinessProbe = {
# 								failureThreshold = 3
# 								httpGet = {
# 									path = "/readyz"
# 									port = "https"
# 									scheme = "HTTPS"
# 								}
# 								periodSeconds = 10								
# 							}
# 							securityContext = {
# 								readOnlyRootFilesystem = true
# 								runAsNonRoot = true
# 								runAsUser = 1000
# 							}
# 							volumeMounts = [
# 								{
# 									mountPath = "/tmp"
# 									name = "tmp-dir"
# 								},
# 							]
# 						},
# 					]
# 					nodeSelector = {
# 						"kubernetes.io/os" = "linux"
# 					}
# 					priorityClassName = "system-cluster-critical"
# 					serviceAccountName = "metrics-server"
# 					volumes = [
# 						{
# 							emptyDir = {}
# 							name = "tmp-dir"
# 						},
# 					]
# 				}
# 			}
# 		}
# 	}
# 	depends_on = [
# 		kubernetes_manifest.metrics_server_service_account,
# 	]
# }