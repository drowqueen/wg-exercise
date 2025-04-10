module "simple-vpc" {
  source           = "terraform-google-modules/network/google"
  project_id       = var.project_id
  network_name     = var.network_name
  subnets          = var.subnets
  secondary_ranges = var.secondary_ranges
}
