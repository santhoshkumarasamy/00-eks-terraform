data "aws_caller_identity" "current" {}

resource "aws_iam_role" "eks_admin" {
  name = "${local.env}-${local.eks-name}-eks-admin-role"
  assume_role_policy = <<POLICY
  {
    "Version" : "2012-10-17",
    "Statement" :[
        {
            "Effect" : "Allow",
            "Action" : "sts:AssumeRole",
            "Principal" : {
                "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            }
        }
    ]
  }
  POLICY
}


resource "aws_iam_policy" "eks_admin" {
  name = "my-AmazonEKSAdminPolicy"
  policy = <<POLICY
  {
    "Version" : "2012-10-17",
    "Statement" :[
        {
            "Effect" : "Allow",
            "Action" : [
                "eks:*"
            ],
            "Resource": "*"
        },
        {
            "Effect" : "Allow",
            "Action" : "iam:PassRole",
            "Resource" : "*",
            "Condition":{
                "StringEquals":{
                    "iam:PassedToService": "eks.amazonaws.com"
                }
            }
        }
    ]
  }
  POLICY
}


resource "aws_iam_role_policy_attachment" "eks_admin" {
  role = aws_iam_role.eks_admin.name
  policy_arn = aws_iam_policy.eks_admin.arn
}

resource "aws_iam_user" "eks-manager" {
  name = "eks-manager"
  lifecycle {
     ignore_changes = [ tags ]
   }
}

resource "aws_iam_policy" "eks_assume_admin" {
  name = "my-AmazonEKSAssumeAdminPolicy"
  policy = <<POLICY
  {
    "Version" : "2012-10-17",
    "Statement" :[
        {
            "Effect": "Allow",
            "Action" : [
                "sts:AssumeRole"
            ],
            "Resource" : "${aws_iam_role.eks_admin.arn}"
        }
    ]
  }
  POLICY
}

resource "aws_iam_user_policy_attachment" "manager_policy" {
  policy_arn = aws_iam_policy.eks_assume_admin.arn
  user = aws_iam_user.eks-manager.name
}

resource "aws_eks_access_entry" "manager" {
    cluster_name = aws_eks_cluster.eks.name
    principal_arn = aws_iam_role.eks_admin.arn
    kubernetes_groups = [ "my-admin" ]
  
}