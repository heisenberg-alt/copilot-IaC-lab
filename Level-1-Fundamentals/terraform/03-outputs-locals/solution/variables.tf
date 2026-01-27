# =============================================================================
# Level 1.3: Variables - Solution
# =============================================================================

variable "environment" {
  description = "The deployment environment"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "The Azure region"
  type        = string
  default     = "eastus"
}

variable "workload" {
  description = "The workload name"
  type        = string
  default     = "iaclab"
}
