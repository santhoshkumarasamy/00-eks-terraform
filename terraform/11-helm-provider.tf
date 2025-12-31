data "aws_eks_cluster" "eks_cluster" {
  name = aws_eks_cluster.eks.name
}

data "aws_eks_cluster_auth" "eks_auth" {
  name = aws_eks_cluster.eks.name
}

provider "helm" {
  kubernetes = {
    host = data.aws_eks_cluster.eks_cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
    token = data.aws_eks_cluster_auth.eks_auth.token
  }
}

## or

# provider "helm" {
#   kubernetes = {
#     host = data.aws_eks_cluster.eks_cluster.endpoint
#     cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
#     exec {
#       api_version = "client.authentication.k8s.io/v1beta"
#       args = ["eks", "get-token","--cluster-name",data.aws_eks_cluster.default.id]
#       command = "aws"
#     }
#   }
# }

## Sample output of "aws eks get-token --cluster-name staging-demo --profile sk"

# {
#     "kind": "ExecCredential",
#     "apiVersion": "client.authentication.k8s.io/v1beta1",
#     "spec": {},
#     "status": {
#         "expirationTimestamp": "2025-10-25T05:09:34Z",
#         "token": "k8s-aws-v1.aHR0cHM6Ly9zdHMuYW1hem9uYXdzLmNvbS8_QWN0aW9uPUdldENhbGxlcklkZW50aXR5JlZlcnNpb249MjAxMS0wNi0xNSZYLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFUNjVYRUkzREczU0IzUDVCJTJGMjAyNTEwMjUlMkZ1cy1lYXN0LTElMkZzdHMlMkZhd3M0X3JlcXVlc3QmWC1BbXotRGF0ZT0yMDI1MTAyNVQwNDU1MzRaJlgtQW16LUV4cGlyZXM9NjAmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0JTNCeC1rOHMtYXdzLWlkJlgtQW16LVNpZ25hdHVyZT03NTIzMWRjNjExM2NjNmJjN2FiZmFkODRlMTVlMWMzNTZlNTcwOWM5YTdmYjRkZDkxNTdjOWM1YmU0MTUwM2Q2"
#     }
# }

# Here if you see in the output the apiVersion should match the apiversion in the command, so that Terraform can parse the token from the output

