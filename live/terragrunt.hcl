# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Automatically load project-level variables
  project_vars = read_terragrunt_config(find_in_parent_folders("project.hcl"))

  # Extract the variables we need for easy access
  project      = local.project_vars.locals.project_id

  # root bucket for managing module state files
  bucket      = "drq-tfstate"
}

remote_state {
  backend = "gcs"
  config = {
    location = "eu"
    bucket   = local.bucket
    prefix   = "${path_relative_to_include()}/tfstate"
    project = local.project
  }
  generate = {
    path = "backend.tf"
    if_exists = "overwrite"
  }
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "gcs" {}
}  
EOF
}
# Configure root level variables that all resources can inherit. This is especially helpful with multi-project and multi-environment 
# configs where terraform_remote_state data sources are placed directly into the modules. 
# These are automatically merged into the child terragrunt.hcl config in subfolders via the include block.

inputs = merge(
  local.project_vars.locals,
)