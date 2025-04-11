# google_client_config and kubernetes provider must be explicitly specified like the following.
data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.this.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.this.ca_certificate)
}

resource "google_service_account" "this" {
  account_id   = var.account_id
  project      = var.project_id
  display_name = "GKE Service Account"
}

resource "google_container_cluster" "this" {
  name                = var.name
  location            = var.location
  project             = var.project_id
  enable_autopilot    = true
  network             = var.network
  subnetwork          = var.subnetwork
  deletion_protection = false

  vertical_pod_autoscaling {
    enabled = true
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = var.ip_range_pods     # subnet secondary range for pods
    services_secondary_range_name = var.ip_range_services # subnet secondary range for services
  }
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
  secret_manager_config {
    enabled = true
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
  }
  node_config {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.this.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
