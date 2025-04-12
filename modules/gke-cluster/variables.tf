variable "project_id" {
  type        = string
  description = "The Google Cloud project ID."
}

variable "name" {
  type        = string
  description = "The name of the GKE cluster."
}

variable "location" {
  type        = string
  description = "The region or zone for the GKE cluster (e.g., europe-west1)."
}

variable "account_id" {
  type        = string
  description = "The ID for the GCP service account (e.g., cosmo-sa)."
}

variable "network" {
  type        = string
  description = "The name of the VPC network."
}

variable "subnetwork" {
  type        = string
  description = "The name of the subnetwork."
}

variable "ip_range_pods" {
  type        = string
  description = "The secondary IP range name for pods."
}

variable "ip_range_services" {
  type        = string
  description = "The secondary IP range name for services."
}
variable "deletion_protection" {
  type        = bool
  description = "Whether to enable deletion protection for the cluster."
  default     = true
}
/*
variable "master_ipv4_cidr_block" {
  type        = string
  description = "This range will be used for assigning private IP addresses to the cluster master(s) and the ILB VIP."
}*/
