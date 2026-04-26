provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}


resource "helm_release" "kube_prometheus_stack" {
  name             = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"

  values = [
    <<-EOT
    grafana:
      adminPassword: "admin"
      service:
        type: LoadBalancer

    prometheus:
      service:
        type: LoadBalancer
    EOT
  ]

  depends_on = [
    null_resource.get_credentials
  ]
}
