resource "helm_release" "cert-manager" {
  name = "cert-manager"

  repository = "https://charts.jetstack.io"
  chart = "cert-manager"
  version = "1.19.1"
  namespace = "certmanager"
  create_namespace = true

  set = [ {
    name = "installCRDs"
    value = "true"
  } ]

  depends_on = [ helm_release.external_ingress ]
}