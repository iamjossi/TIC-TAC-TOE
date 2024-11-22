# Fetch details about the EKS cluster
data "aws_eks_cluster" "example" {
  name = aws_eks_cluster.example.name
}

# Fetch the authentication token for the EKS cluster
data "aws_eks_cluster_auth" "example" {
  name = aws_eks_cluster.example.name
}
