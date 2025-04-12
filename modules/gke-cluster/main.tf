# Enable required APIs
resource "google_project_service" "secretmanager" {
  project = var.project_id
  service = "secretmanager.googleapis.com"
}

# Google client config and Kubernetes provider
data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.this.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.this.master_auth.0.cluster_ca_certificate)
}

# GCP service account (cosmo-sa)
resource "google_service_account" "this" {
  account_id   = var.account_id
  project      = var.project_id
  display_name = "GKE Autopilot Service Account"
}

# IAM roles for least privilege
resource "google_project_iam_member" "this" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/secretmanager.secretAccessor",
    "roles/container.clusterViewer"
  ])
  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.this.email}"
}

# GKE Autopilot cluster
resource "google_container_cluster" "this" {
  name                = var.name
  location            = var.location
  project             = var.project_id
  enable_autopilot    = true
  network             = var.network
  subnetwork          = var.subnetwork
  deletion_protection = var.deletion_protection

  vertical_pod_autoscaling {
    enabled = true
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = var.ip_range_pods
    services_secondary_range_name = var.ip_range_services
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  secret_manager_config {
    enabled = true # For secret integration
  }

  /*  private_cluster_config {
    enable_private_nodes    = true 
    enable_private_endpoint = true
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }*/

  monitoring_config {
    enable_components = [
      "SYSTEM_COMPONENTS",
      "APISERVER",
      "SCHEDULER",
      "CONTROLLER_MANAGER",
      "STORAGE",
      "HPA",
      "POD",
      "DAEMONSET",
      "DEPLOYMENT",
      "STATEFULSET",
      "KUBELET",
      "CADVISOR"
    ]
  }
}

# Monitoring namespace
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

# App service account
resource "kubernetes_service_account" "app" {
  metadata {
    name      = "app-sa"
    namespace = "default"
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.this.email
    }
  }
}

# Prometheus service account
resource "kubernetes_service_account" "prometheus" {
  metadata {
    name      = "prometheus-sa"
    namespace = kubernetes_namespace.monitoring.metadata.0.name
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.this.email
    }
  }
}

# Workload identity for app-sa
resource "google_service_account_iam_binding" "app_identity" {
  service_account_id = google_service_account.this.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[default/app-sa]"
  ]
}

# Workload identity for prometheus-sa
resource "google_service_account_iam_binding" "prometheus_identity" {
  service_account_id = google_service_account.this.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[${kubernetes_namespace.monitoring.metadata.0.name}/prometheus-sa]"
  ]
}

# Sample app pod
resource "kubernetes_pod" "app" {
  metadata {
    name      = "app-pod"
    namespace = "default"
  }
  spec {
    container {
      name    = "testpod"
      image   = "curlimages/curl:latest"
      command = ["sh", "-c", "sleep 3600"] # Keep pod running for testing
    }
    service_account_name = kubernetes_service_account.app.metadata.0.name
  }
}
