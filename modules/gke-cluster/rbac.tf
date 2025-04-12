# RBAC for app-sa
resource "kubernetes_role" "app_role" {
  metadata {
    name      = "app-role"
    namespace = "default"
  }
  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_role_binding" "app_role_binding" {
  metadata {
    name      = "app-role-binding"
    namespace = "default"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.app_role.metadata.0.name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.app.metadata.0.name
    namespace = "default"
  }
}

# RBAC for prometheus-sa
resource "kubernetes_role" "prometheus_role" {
  metadata {
    name      = "prometheus-role"
    namespace = kubernetes_namespace.monitoring.metadata.0.name
  }
  rule {
    api_groups = [""]
    resources  = ["pods", "services", "endpoints"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding" "prometheus_role_binding" {
  metadata {
    name      = "prometheus-role-binding"
    namespace = kubernetes_namespace.monitoring.metadata.0.name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.prometheus_role.metadata.0.name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.prometheus.metadata.0.name
    namespace = kubernetes_namespace.monitoring.metadata.0.name
  }
}
