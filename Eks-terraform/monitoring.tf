# Define the AWS provider
provider "aws" {
  region = "eu-west-2"
}

# Fetch the EKS cluster credentials and details
data "aws_eks_cluster" "example" {
  name = "EKS_CLOUD"
}

data "aws_eks_cluster_auth" "example" {
  name = "EKS_CLOUD"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.example.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.example.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.example.token
}

# IAM role for Prometheus
resource "aws_iam_role" "prometheus_role" {
  name = "PrometheusRole"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

# Attach the policies to the Prometheus IAM role
resource "aws_iam_role_policy_attachment" "prometheus_policy_attachment" {
  role       = aws_iam_role.prometheus_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonCloudWatchFullAccess"
}

# IAM role for Grafana
resource "aws_iam_role" "grafana_role" {
  name = "GrafanaRole"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

# Attach the policies to the Grafana IAM role
resource "aws_iam_role_policy_attachment" "grafana_policy_attachment" {
  role       = aws_iam_role.grafana_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonCloudWatchFullAccess"
}

# Prometheus Deployment
resource "kubernetes_deployment" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = "monitoring"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "prometheus"
      }
    }

    template {
      metadata {
        labels = {
          app = "prometheus"
        }
      }

      spec {
        container {
          name  = "prometheus"
          image = "prom/prometheus:v2.30.3"
          ports {
            container_port = 9090
          }
        }
      }
    }
  }
}

# Grafana Deployment
resource "kubernetes_deployment" "grafana" {
  metadata {
    name      = "grafana"
    namespace = "monitoring"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "grafana"
      }
    }

    template {
      metadata {
        labels = {
          app = "grafana"
        }
      }

      spec {
        container {
          name  = "grafana"
          image = "grafana/grafana:8.3.3"
          ports {
            container_port = 3000
          }
        }
      }
    }
  }
}

# Service for Prometheus
resource "kubernetes_service" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = "monitoring"
  }

  spec {
    selector = {
      app = "prometheus"
    }

    port {
      port        = 9090
      target_port = 9090
    }

    type = "LoadBalancer"
  }
}

# Service for Grafana
resource "kubernetes_service" "grafana" {
  metadata {
    name      = "grafana"
    namespace = "monitoring"
  }

  spec {
    selector = {
      app = "grafana"
    }

    port {
      port        = 3000
      target_port = 3000
    }

    type = "LoadBalancer"
  }
}

