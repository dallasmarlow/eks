# The dashboard namespace must be created before terraform plan or apply can be run with
# the terraform kubernetes-alpha resources defined as even when the namespace is a defined
# resource with deps declared, terraform crashes w/ the following errors:

# Error: rpc error: code = Unknown desc = update dry-run for 'kubernetes-dashboard/kubernetes-dashboard-certs' failed: namespaces "kubernetes-dashboard" not found
# Error: rpc error: code = Unknown desc = update dry-run for 'kubernetes-dashboard/kubernetes-dashboard-key-holder' failed: namespaces "kubernetes-dashboard" not found
# Error: rpc error: code = Unknown desc = update dry-run for 'kubernetes-dashboard/dashboard-metrics-scraper' failed: namespaces "kubernetes-dashboard" not found
# Error: rpc error: code = Unknown desc = update dry-run for 'kubernetes-dashboard/kubernetes-dashboard' failed: namespaces "kubernetes-dashboard" not found
# Error: rpc error: code = Unknown desc = update dry-run for 'kubernetes-dashboard/kubernetes-dashboard' failed: namespaces "kubernetes-dashboard" not found
# Error: rpc error: code = Unknown desc = update dry-run for 'kubernetes-dashboard/kubernetes-dashboard-csrf' failed: namespaces "kubernetes-dashboard" not found
# Error: rpc error: code = Unknown desc = update dry-run for 'kubernetes-dashboard/kubernetes-dashboard-settings' failed: namespaces "kubernetes-dashboard" not found

# resource "kubernetes_manifest" "dashboard_namespace" {
# 	provider = kubernetes-alpha
# 	manifest = {
# 		apiVersion = "v1"
# 		kind = "Namespace"
# 		metadata = {
# 			name = "kubernetes-dashboard"
# 		}
# 	}
# }

# resource "kubernetes_namespace" "dashboard_namespace" {
# 	metadata {
# 		name = "kubernetes-dashboard"
# 	}
# }

# resource "kubernetes_manifest" "dashboard_service_account" {
# 	provider = kubernetes-alpha
# 	manifest = {
# 		apiVersion = "v1"
# 		kind = "ServiceAccount"
# 		metadata = {
# 			labels = {
# 				"k8s-app": "kubernetes-dashboard"
# 			}
# 			name = "kubernetes-dashboard"
# 			namespace = "kubernetes-dashboard"
# 		}
# 	}
# 	# depends_on = [
# 	# 	kubernetes_namespace.dashboard_namespace,
# 	# ]
# }

# resource "kubernetes_manifest" "dashboard_service" {
# 	provider = kubernetes-alpha
# 	manifest = {
# 		apiVersion = "v1"
# 		kind = "Service"
# 		metadata = {
# 			labels = {
# 				"k8s-app": "kubernetes-dashboard"
# 			}
# 			name = "kubernetes-dashboard"
# 			namespace = "kubernetes-dashboard"
# 		}
# 		spec = {
# 			ports = [
# 				{
# 					port = 443
# 					protocol = "TCP"
# 					targetPort = 8443
# 				},
# 			]
# 			selector = {
# 				"k8s-app": "kubernetes-dashboard"
# 			}
# 		}
# 	}
# 	# depends_on = [
# 	# 	kubernetes_namespace.dashboard_namespace,
# 	# ]
# }

# resource "kubernetes_manifest" "dashboard_service_metrics_scraper" {
# 	provider = kubernetes-alpha
# 	manifest = {
# 		apiVersion = "v1"
# 		kind = "Service"
# 		metadata = {
# 			labels = {
# 				"k8s-app": "dashboard-metrics-scraper"
# 			}
# 			name = "dashboard-metrics-scraper"
# 			namespace = "kubernetes-dashboard"
# 		}
# 		spec = {
# 			ports = [
# 				{
# 					port = 8000
# 					protocol = "TCP"
# 					targetPort = 8000
# 				},
# 			]
# 			selector = {
# 				"k8s-app": "dashboard-metrics-scraper"
# 			}
# 		}
# 	}
# 	# depends_on = [
# 	# 	kubernetes_namespace.dashboard_namespace,
# 	# ]
# }

# resource "kubernetes_manifest" "dashboard_secret_certs" {
# 	provider = kubernetes-alpha
# 	manifest = {
# 		apiVersion = "v1"
# 		kind = "Secret"
# 		metadata = {
# 			labels = {
# 				"k8s-app": "kubernetes-dashboard"
# 			}
# 			name = "kubernetes-dashboard-certs"
# 			namespace = "kubernetes-dashboard"
# 		}
# 		type = "Opaque"
# 	}
# 	# depends_on = [
# 	# 	kubernetes_namespace.dashboard_namespace,
# 	# ]
# }

# resource "kubernetes_manifest" "dashboard_secret_csrf" {
# 	provider = kubernetes-alpha
# 	manifest = {
# 		apiVersion = "v1"
# 		kind = "Secret"
# 		metadata = {
# 			labels = {
# 				"k8s-app": "kubernetes-dashboard"
# 			}
# 			name = "kubernetes-dashboard-csrf"
# 			namespace = "kubernetes-dashboard"
# 		}
# 		type = "Opaque"
# 		data = {
# 			csrf = ""
# 		}
# 	}
# 	# depends_on = [
# 	# 	kubernetes_namespace.dashboard_namespace,
# 	# ]
# }

# resource "kubernetes_manifest" "dashboard_secret_key_holder" {
# 	provider = kubernetes-alpha
# 	manifest = {
# 		apiVersion = "v1"
# 		kind = "Secret"
# 		metadata = {
# 			labels = {
# 				"k8s-app": "kubernetes-dashboard"
# 			}
# 			name = "kubernetes-dashboard-key-holder"
# 			namespace = "kubernetes-dashboard"
# 		}
# 		type = "Opaque"
# 	}
# 	# depends_on = [
# 	# 	kubernetes_namespace.dashboard_namespace,
# 	# ]
# }

# resource "kubernetes_manifest" "dashboard_config_map_settings" {
# 	provider = kubernetes-alpha
# 	manifest = {
# 		apiVersion = "v1"
# 		kind = "ConfigMap"
# 		metadata = {
# 			labels = {
# 				"k8s-app": "kubernetes-dashboard"
# 			}
# 			name = "kubernetes-dashboard-settings"
# 			namespace = "kubernetes-dashboard"
# 		}
# 	}
# 	# depends_on = [
# 	# 	kubernetes_namespace.dashboard_namespace,
# 	# ]
# }

# resource "kubernetes_manifest" "dashboard_role" {
# 	provider = kubernetes-alpha
# 	manifest = {
# 		apiVersion = "rbac.authorization.k8s.io/v1"
# 		kind = "Role"
# 		metadata = {
# 			labels = {
# 				"k8s-app": "kubernetes-dashboard"
# 			}
# 			name = "kubernetes-dashboard"
# 			namespace = "kubernetes-dashboard"
# 		}
# 		rules = [
# 			{
# 				apiGroups = [""]
# 				resources = ["secrets"]
# 				resourceNames = [
# 					"kubernetes-dashboard-key-holder",
# 					"kubernetes-dashboard-certs",
# 					"kubernetes-dashboard-csrf",
# 				]
# 				verbs = ["get", "update", "delete"]
# 			},
# 			{
# 				apiGroups = [""]
# 				resources = ["configmaps"]
# 				resourceNames = ["kubernetes-dashboard-settings"]
# 				verbs = ["get", "update"]
# 			},
# 			{
# 				apiGroups = [""]
# 				resources = ["services"]
# 				resourceNames = ["heapster", "dashboard-metrics-scraper"]
# 				verbs = ["proxy"]
# 			},
# 			{
# 				apiGroups = [""]
# 				resources = ["services/proxy"]
# 				resourceNames = [
# 					"heapster",
# 					"http:heapster:",
# 					"https:heapster:",
# 					"dashboard-metrics-scraper",
# 					"http:dashboard-metrics-scraper",
# 				]
# 				verbs = ["get"]
# 			},
# 		]
# 	}
# 	depends_on = [
# 		# kubernetes_namespace.dashboard_namespace,
# 		kubernetes_manifest.dashboard_config_map_settings,
# 		kubernetes_manifest.dashboard_secret_key_holder,
# 		kubernetes_manifest.dashboard_secret_csrf,
# 		kubernetes_manifest.dashboard_secret_certs,
# 	]
# }

# resource "kubernetes_manifest" "dashboard_cluster_role" {
# 	provider = kubernetes-alpha
# 	manifest = {
# 		apiVersion = "rbac.authorization.k8s.io/v1"
# 		kind = "ClusterRole"
# 		metadata = {
# 			labels = {
# 				"k8s-app": "kubernetes-dashboard"
# 			}
# 			name = "kubernetes-dashboard"
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

# resource "kubernetes_manifest" "dashboard_role_binding" {
# 	provider = kubernetes-alpha
# 	manifest = {
# 		apiVersion = "rbac.authorization.k8s.io/v1"
# 		kind = "RoleBinding"
# 		metadata = {
# 			labels = {
# 				"k8s-app": "kubernetes-dashboard"
# 			}
# 			name = "kubernetes-dashboard"
# 			namespace = "kubernetes-dashboard"
# 		}
# 		roleRef = {
# 			apiGroup = "rbac.authorization.k8s.io"
# 			kind = "Role"
# 			name = "kubernetes-dashboard"
# 		}
# 		subjects = [
# 			{
# 				kind = "ServiceAccount"
# 				name = "kubernetes-dashboard"
# 				namespace = "kubernetes-dashboard"
# 			},
# 		]
# 	}
# 	depends_on = [
# 		# kubernetes_namespace.dashboard_namespace,
# 		kubernetes_manifest.dashboard_service_account,
# 		kubernetes_manifest.dashboard_role,
# 	]
# }

# resource "kubernetes_manifest" "dashboard_cluster_role_binding" {
# 	provider = kubernetes-alpha
# 	manifest = {
# 		apiVersion = "rbac.authorization.k8s.io/v1"
# 		kind = "ClusterRoleBinding"
# 		metadata = {
# 			name = "kubernetes-dashboard"
# 		}
# 		roleRef = {
# 			apiGroup = "rbac.authorization.k8s.io"
# 			kind = "ClusterRole"
# 			name = "kubernetes-dashboard"
# 		}
# 		subjects = [
# 			{
# 				kind = "ServiceAccount"
# 				name = "kubernetes-dashboard"
# 				namespace = "kubernetes-dashboard"
# 			},
# 		]
# 	}
# 	depends_on = [
# 		# kubernetes_namespace.dashboard_namespace,
# 		kubernetes_manifest.dashboard_service_account,
# 		kubernetes_manifest.dashboard_cluster_role,
# 	]
# }

# resource "kubectl_manifest" "dashboard_deployment" {
# 	yaml_body = file("${path.module}/manifests/dashboard/deployment.yaml")
# 	depends_on = [
# 		kubernetes_manifest.dashboard_cluster_role_binding,
# 	]
# }

# resource "kubectl_manifest" "dashboard_deployment_metrics_scraper" {
# 	yaml_body = file("${path.module}/manifests/dashboard/deployment_metrics_scraper.yaml")
# 	depends_on = [
# 		kubernetes_manifest.dashboard_cluster_role_binding,
# 	]
# }