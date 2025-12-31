data "aws_iam_policy_document" "ebs_csi_driver" {
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


resource "aws_iam_role" "ebs_csi_driver" {
  name = "my-${aws_eks_cluster.eks.name}-ebs-csi-driver"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_driver.json
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role = aws_iam_role.ebs_csi_driver.name
}

#if you want to encrypt the ebs volume
resource "aws_iam_policy" "ebs_csi_driver_encryption" {
  name = "my-${aws_eks_cluster.eks.name}-ebs-csi-driver-encryption"
  policy = jsonencode(
    {
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Resource = "*"
                Action = [
                    "kms:Decrypt",
                    "kms:CreateGrant",
                    "kms:GenerateDataKeyWithoutPlainText"
                ]
            }
        ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver_encryption" {
  policy_arn = aws_iam_policy.ebs_csi_driver_encryption.arn
  role = aws_iam_role.ebs_csi_driver.name
}

resource "aws_eks_pod_identity_association" "ebs_csi_driver" {
  cluster_name = aws_eks_cluster.eks.name
  service_account = "ebs-csi-controller-sa"
  namespace = "kube-system"
  role_arn = aws_iam_role.ebs_csi_driver.arn
}

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name = aws_eks_cluster.eks.name
  addon_name = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi_driver.arn
  addon_version = "v1.51.1-eksbuild.1"
}

# aws eks describe-addon-versions --addon-name=aws-ebs-csi-driver --region=us-east-2 --profile sk