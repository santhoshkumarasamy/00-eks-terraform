resource "helm_release" "secrets-csi-driver" {
  name = "secrets-store-csi-driver"

  repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  chart      = "secrets-store-csi-driver"
  version    = "1.5.4"
  namespace  = "kube-system"


  set = [{
    name = "syncSecret.enabled"
    value = "true"
  }]

  depends_on = [helm_release.efs-csi-driver]
}

resource "helm_release" "secrets-csi-driver-aws-provider" {
  name = "secrets-store-csi-driver-aws-provider"

  repository = "https://aws.github.io/secrets-store-csi-driver-provider-aws/"
  version    = "2.1.1"
  namespace  = "kube-system"
  chart      = "secrets-store-csi-driver-provider-aws"

  depends_on = [helm_release.secrets-csi-driver]

  set = [ {
    name  = "secrets-store-csi-driver.install"
    value = "false"
  } ]
}

data "aws_iam_policy_document" "secrets-csi" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:12-example:myapp"]
    }
  }
}


resource "aws_iam_role" "csi-provider" {
  name               = "my-${aws_eks_cluster.eks.name}-myapp-secret"
  assume_role_policy = data.aws_iam_policy_document.secrets-csi.json
}

resource "aws_iam_policy" "myapp-secret-policy" {
  name = "my-${aws_eks_cluster.eks.name}-myapp-secret-policy"
  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret"
          ]
          Resource = "*"
        }
      ]

    }
  )
}

resource "aws_iam_role_policy_attachment" "secret-csi-provider" {
  policy_arn = aws_iam_policy.myapp-secret-policy.arn
  role       = aws_iam_role.csi-provider.name
}

output "myapp_secrets_role_arn" {
  value = aws_iam_role.csi-provider.arn
}
