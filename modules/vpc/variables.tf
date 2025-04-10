variable "network_name" {
  type = string
}

variable "project_id" {
  type = string
}

variable "subnets" {
  type = list(map(string))
}

variable "secondary_ranges" {
  type    = map(list(object({ range_name = string, ip_cidr_range = string })))
  default = null
}

variable "routes" {
  type = list(map(string))
}