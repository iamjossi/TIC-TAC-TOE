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
        port: 9090
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
      port: 3000
    EOF
  ]

  depends_on = [kubernetes_namespace.monitoring]
}

# Outputs for accessing the monitoring tools
output "prometheus_endpoint" {
  value = "http://${aws_instance.example.public_ip}:9090"
  description = "Access Prometheus using this endpoint."
}

output "grafana_endpoint" {
  value = "http://${aws_instance.example.public_ip}:3000"
  description = "Access Grafana using this endpoint."
}
