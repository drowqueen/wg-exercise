include {
  path = find_in_parent_folders()
}

locals {
  project_vars = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  project_id       = local.project_vars.locals.project_id
}

terraform {
  source = "../../..//modules/vpc"
}

inputs = {
  network_name = "main-vpc"
  project_id   = local.project_id
  subnets = [
    {
      subnet_name           = "subnet01"
      subnet_ip             = "10.10.1.0/24"
      subnet_region         = "europe-west1"
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
    }
  ]
  # Secondary ranges are needed to separate Kubernetes pods from the main cluster IP range
  secondary_ranges = {
    subnet01 = [
      {
        range_name    = "subnet01-pods"
        ip_cidr_range = "172.16.0.0/20"  # 4096 IPs for Pods
      }, 
      {
        range_name    = "subnet01-services"
        ip_cidr_range = "172.16.16.0/20" # 4096 IPs for Services
      }
    ]
  }

  routes = [
    {
      name              = "egress-internet"
      description       = "route through IGW to access internet"
      destination_range = "0.0.0.0/0"
      tags              = "egress-inet"
      next_hop_internet = "true"
    }
  ]
}