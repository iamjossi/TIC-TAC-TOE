# Fetch details about the EKS cluster
data "aws_eks_cluster" "eks_details" {
  name = aws_eks_cluster.example.name
}

# Fetch the authentication token for the EKS cluster
data "aws_eks_cluster_auth" "eks_auth" {
  name = aws_eks_cluster.example.name
}
