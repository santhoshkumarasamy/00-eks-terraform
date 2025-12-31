#Check example 1

resource "aws_iam_user" "dev" {
  name = "developer"

  lifecycle {
     ignore_changes = [ tags ]
   }
}

resource "aws_iam_policy" "developer_eks" {
  name = "my-AmazonEKSDeveloperPolicy"

  policy = <<POLICY
  {
    "Version":"2012-10-17",
    "Statement":[
        {
            "Effect": "Allow",
            "Action":[
                "eks:DescribeCluster",
                "eks:ListCluster"
            ],
            "Resource": "*"
        }
    ]
  }
  POLICY
}

resource "aws_iam_user_policy_attachment" "developer_eks" {
  user = aws_iam_user.dev.name
  policy_arn = aws_iam_policy.developer_eks.arn
}

resource "aws_eks_access_entry" "developer" {
  cluster_name = aws_eks_cluster.eks.name
  principal_arn = aws_iam_user.dev.arn
  kubernetes_groups = [ "my-viewers" ]
}


