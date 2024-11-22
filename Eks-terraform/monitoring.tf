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

# Outputs for accessing the monitoring tools
output "prometheus_endpoint" {
  value = helm_release.prometheus.status.load_balancer[0].ingress[0].hostname
  description = "Access Prometheus using this endpoint."
}

output "grafana_endpoint" {
  value = helm_release.grafana.status.load_balancer[0].ingress[0].hostname
  description = "Access Grafana using this endpoint."
}
