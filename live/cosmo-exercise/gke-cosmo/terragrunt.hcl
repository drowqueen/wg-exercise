
include {
  path = find_in_parent_folders()
}

locals {
  project_vars = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  project_id    = local.project_vars.locals.project_id
}

terraform {
  source = "../../..//modules/gke-cluster"
}

dependency "vpc" {
  config_path = "../main-vpc"
}

inputs = {
  name                       = "cosmo"
  account_id                 = "cosmo-sa"
  project_id                 = local.project_id
  location                   = "europe-west1"
  network                    = dependency.vpc.outputs.network_name
  subnetwork                 = "subnet01"
  ip_range_pods              = "subnet01-pods"
  ip_range_services          = "subnet01-services"
  deletion_protection        = false    # Set true for production
#  master_ipv4_cidr_block     = "172.16.32.0/28"
}