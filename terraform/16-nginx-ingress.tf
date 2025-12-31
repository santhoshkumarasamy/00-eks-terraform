resource "helm_release" "external_ingress" {
  name = "external-ingress"

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"
  namespace = "ingress"
  create_namespace = true
  version = "4.13.3"

  values = [file("${path.module}/values/nginx-ingress.yaml")]
  depends_on = [ helm_release.aws_lbc ]
  
}