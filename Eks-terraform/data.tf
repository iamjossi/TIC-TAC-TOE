data "aws_eks_cluster" "example" {
  name = aws_eks_cluster.example.name
}

data "aws_eks_cluster_auth" "example" {
  name = aws_eks_cluster.example.name
}
