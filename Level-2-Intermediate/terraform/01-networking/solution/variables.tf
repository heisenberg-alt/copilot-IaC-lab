# =============================================================================
# Level 2.1: Variables - Solution
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

variable "vnet_address_space" {
  description = "Address space for the Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnets" {
  description = "Map of subnet configurations"
  type = map(object({
    address_prefix    = string
    service_endpoints = optional(list(string), [])
  }))
  default = {
    web = {
      address_prefix    = "10.0.1.0/24"
      service_endpoints = []
    }
    app = {
      address_prefix    = "10.0.2.0/24"
      service_endpoints = ["Microsoft.Storage"]
    }
    db = {
      address_prefix    = "10.0.3.0/24"
      service_endpoints = ["Microsoft.Sql"]
    }
  }
}

locals {
  common_tags = {
    environment = var.environment
    project     = var.workload
    managed_by  = "terraform"
  }
}
