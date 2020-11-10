# data "helm_repository" "jetstack" {
# 	name = "jetstack"
# 	url = "https://charts.jetstack.io"
# }

# resource "kubernetes_manifest" "cert_manager" {
# 	provider = kubernetes-alpha
# 	manifest = {
# 		apiVersion = "v1"
# 		kind = "Namespace"
# 		metadata = {
# 			labels = {
# 				"certmanager.k8s.io/disable-validation" = "true"
# 			}
# 			name = "cert-manager"
# 		}
# 	}
# }

# resource "helm_release" "cert-manager" {
# 	chart = "jetstack/cert-manager"
# 	name = "cert-manager"
# 	namespace = "cert-manager"
# 	repository = data.helm_repository.jetstack.metadata[0].name
# 	version = "v1.0.4"
# 	set {
# 		name = "installCRDs"
# 		value = "true"
# 	}
# 	depends_on = [
# 		kubernetes_manifest.cert_manager,
# 	]
# }