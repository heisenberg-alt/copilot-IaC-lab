# =============================================================================
# Level 2.1: Variables - Challenge
# =============================================================================

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "workload" {
  description = "Workload name"
  type        = string
  default     = "network"
}

# TODO: Create a variable "vnet_address_space" for the VNet CIDR (default: ["10.0.0.0/16"])


# TODO: Create a variable "subnets" as a map of objects with:
# - address_prefix (string)
# - service_endpoints (optional list of strings)

locals {
  common_tags = {
    environment = var.environment
    project     = var.workload
    managed_by  = "terraform"
  }
}
