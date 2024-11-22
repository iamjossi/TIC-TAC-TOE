# Configure the Helm provider
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.example.endpoint
    token                  = data.aws_eks_cluster_auth.example.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.example.certificate_authority[0].data)
  }
}

# Create a namespace for monitoring
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

# Deploy Prometheus using Helm
resource "helm_release" "prometheus" {
  name       = "prometheus"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"

  values = [
    <<EOF
    alertmanager:
      enabled: true
    server:
      service:
        type: LoadBalancer
    EOF
  ]

  depends_on = [kubernetes_namespace.monitoring]
}

# Deploy Grafana using Helm
resource "helm_release" "grafana" {
  name       = "grafana"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"

  values = [
    <<EOF
    adminUser: "admin"
    adminPassword: "admin"
    service:
      type: LoadBalancer
    EOF
  ]

  depends_on = [kubernetes_namespace.monitoring]
}

# Reference the existing EC2 instance
data "aws_instance" "monitoring_instance" {
  instance_id = "i-07bd5d19a7aae5470" # Replace with your existing instance ID
}

# Outputs for accessing the monitoring tools
output "prometheus_endpoint" {
  value = "http://${data.aws_instance.monitoring_instance.public_ip}:9090"
}

output "grafana_endpoint" {
  value = "http://${data.aws_instance.monitoring_instance.public_ip}:3000"
}
