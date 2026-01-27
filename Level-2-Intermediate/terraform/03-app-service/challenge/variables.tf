# =============================================================================
# Level 2.3: Variables - Challenge
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
  default     = "webapp"
}

variable "app_settings" {
  description = "Application settings for the web app"
  type        = map(string)
  default = {
    "ENVIRONMENT" = "development"
  }
}

locals {
  common_tags = {
    environment = var.environment
    project     = var.workload
    managed_by  = "terraform"
  }
}
