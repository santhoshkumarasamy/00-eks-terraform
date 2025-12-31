resource "aws_eks_addon" "pod-identity" {
  cluster_name = aws_eks_cluster.eks.name
  addon_name = "eks-pod-identity-agent"
  addon_version = "v1.3.9-eksbuild.3"
}


# to get addon addon_version
# aws eks describe-addon-versions --region us-east-2 --addon-name eks-pod-identity-agent --profile sk