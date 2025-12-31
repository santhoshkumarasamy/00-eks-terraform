resource "aws_iam_role" "nodes" {
  name               = "${local.env}-${local.eks-name}-nodes"
  assume_role_policy = <<POLICY
  {
    "Version" : "2012-10-17",
    "Statement" : [
        {
            "Effect": "Allow",
            "Action" :"sts:AssumeRole",
            "Principal":{
                "Service": "ec2.amazonaws.com"
            }
        }
    ]
  }
  POLICY
}

resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "amazon_eks_container_registry_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

resource "aws_eks_node_group" "general" {
  cluster_name    = aws_eks_cluster.eks.name
  version         = local.eks-version
  node_group_name = "general"
  node_role_arn   = aws_iam_role.nodes.arn

  subnet_ids = [
    aws_subnet.private_zone1.id,
    aws_subnet.private_zone2.id
  ]
  capacity_type = "ON_DEMAND"
  # instance_types = ["t3.large"]
  launch_template {
    id      = aws_launch_template.eks-launch-template.id
    version = aws_launch_template.eks-launch-template.default_version
  }

  scaling_config {
    desired_size = 1
    max_size     = 10
    min_size     = 0
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  depends_on = [
    aws_launch_template.eks-launch-template,
    aws_iam_role_policy_attachment.amazon_eks_cni_policy,
    aws_iam_role_policy_attachment.amazon_eks_container_registry_read_only,
    aws_iam_role_policy_attachment.amazon_eks_worker_node_policy
  ]

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}
