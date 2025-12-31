resource "helm_release" "metrics_server" {
  name = "metrics-server"

  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart = "metrics-server"
  namespace = "kube-system"
  version = "3.12.1"

  values = [
    file("${path.module}/values/metrics-server.yaml")
  ]
  
# this is set the value of the helm chart you can also set the values using below method 
#   set = [ {
#     name = "replicaCount"
#     value =1
#    } ]

# and you can also use templatefile function
    

  depends_on = [ aws_eks_node_group.general ]
}