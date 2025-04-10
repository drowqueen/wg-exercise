output "id" {
  value = google_container_cluster.this.id
}

output "endpoint" {
  value     = google_container_cluster.this.endpoint
  sensitive = true
}
