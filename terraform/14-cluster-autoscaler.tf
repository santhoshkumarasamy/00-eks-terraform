resource "aws_iam_role" "cluster_autoscaler" {
  name = "my-${local.env}-${aws_eks_cluster.eks.name}-cluster-auto-scaler"

  assume_role_policy = jsonencode(
    {
        Version = "2012-10-17"
        Statement =[
            {
                Action = [
                    "sts:AssumeRole",
                    "sts:TagSession"
                ]
                Effect = "Allow"
                Principal={
                    Service = "pods.eks.amazonaws.com"
                }
            }
        ]
    }
  )
}

resource "aws_iam_policy" "cluster_autoscaler" {
  name = "my-${aws_eks_cluster.eks.name}-cluster-autoscaler"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Effect = "Allow"
            Action =[
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeScalingActivities",
                "autoscaling:DescribeTags",
                "ec2:DescribeImages",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeLaunchTemplateVersions",
                "ec2:GetInstanceTypesFromInstanceRequirements",
                "eks:DescribeNodegroup"
            ]
            Resource = "*"
        },
        {
            Effect = "Allow"
            Action = [
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup"
            ]
            Resource = "*"
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_autoscaler" {
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
  role = aws_iam_role.cluster_autoscaler.name
}

resource "aws_eks_pod_identity_association" "cluster_autoscaler" {
  cluster_name = aws_eks_cluster.eks.name
  namespace = "kube-system"
  service_account = "cluster-autoscaler"
  role_arn = aws_iam_role.cluster_autoscaler.arn
}

resource "helm_release" "eks-autoscaler" {
  name = "autoscaller"

  repository = "https://kubernetes.github.io/autoscaler"
  chart = "cluster-autoscaler"
  namespace = "kube-system"
  version = "9.52.1"

  set = [ 
    {
        name = "rbac.serviceAccount.name"
        value = "cluster-autoscaler"
    },
    {
        name = "autoDiscovery.clusterName"
        value = aws_eks_cluster.eks.name
    },
    {
        name = "awsRegion"
        value = local.region
    }
   ]

   depends_on = [ helm_release.metrics_server ]
}