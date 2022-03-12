# resource "kubernetes_namespace" "kubernetes_dashboard" {
# 	metadata {
# 		name = "kubernetes-dashboard"
# 	}
# }

# # todo: vendor chart
# resource "helm_release" "dashboard" {
# 	chart = "kubernetes-dashboard"
# 	name = "kubernetes-dashboard"
# 	namespace = "kubernetes-dashboard"
# 	repository = "https://kubernetes.github.io/dashboard/"
# 	version = var.kubernetes_dashboard_chart_version
# 	set {
# 		name = "metricsScraper.enabled"
# 		value = "true"
# 	}
# 	depends_on = [
# 		kubernetes_namespace.kubernetes_dashboard,
# 	]
# }