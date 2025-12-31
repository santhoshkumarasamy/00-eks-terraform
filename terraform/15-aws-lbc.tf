data "aws_iam_policy_document" "aws_lbc" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [ "pods.eks.amazonaws.com" ]
    }

    actions = [ 
        "sts:AssumeRole",
        "sts:TagSession"
     ]
  }
}


resource "aws_iam_role" "aws_lbc" {
  name = "my-${aws_eks_cluster.eks.name}-aws-lbc"
  assume_role_policy = data.aws_iam_policy_document.aws_lbc.json
}

resource "aws_iam_policy" "aws_lbc" {
  policy = file("${path.module}/iam/AWSLoadBalancerController.json")
  name = "my-${aws_eks_cluster.eks.name}-aws-lbc"
}


resource "aws_iam_role_policy_attachment" "aws_lbc" {
  policy_arn = aws_iam_policy.aws_lbc.arn
  role = aws_iam_role.aws_lbc.name
}

resource "aws_eks_pod_identity_association" "aws_lbc" {
  namespace = "kube-system"
  role_arn = aws_iam_role.aws_lbc.arn
  service_account = "aws-load-balancer-controller"
  cluster_name = aws_eks_cluster.eks.name
}

resource "helm_release" "aws_lbc" {
  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart = "aws-load-balancer-controller"
  version = "1.14.1"
  namespace = "kube-system"

  set = [ 
    {
        name = "serviceAccount.name"
        value = "aws-load-balancer-controller"
    },
    {
        name = "clusterName"
        value = aws_eks_cluster.eks.name
    }
  ]

  depends_on = [ helm_release.eks-autoscaler ]
}