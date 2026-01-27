# =============================================================================
# Storage Module - Variables
# =============================================================================

variable "storage_account_name" {
  description = "The name of the storage account (must be globally unique)"
  type        = string

  validation {
    condition     = length(var.storage_account_name) >= 3 && length(var.storage_account_name) <= 24
    error_message = "Storage account name must be between 3 and 24 characters."
  }

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.storage_account_name))
    error_message = "Storage account name can only contain lowercase letters and numbers."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region for the storage account"
  type        = string
}

variable "account_tier" {
  description = "The tier of the storage account (Standard or Premium)"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "Account tier must be Standard or Premium."
  }
}

variable "replication_type" {
  description = "The replication type (LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS)"
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.replication_type)
    error_message = "Invalid replication type."
  }
}

variable "access_tier" {
  description = "The access tier (Hot or Cool)"
  type        = string
  default     = "Hot"

  validation {
    condition     = contains(["Hot", "Cool"], var.access_tier)
    error_message = "Access tier must be Hot or Cool."
  }
}

variable "enable_versioning" {
  description = "Enable blob versioning"
  type        = bool
  default     = true
}

variable "soft_delete_days" {
  description = "Number of days for soft delete retention (0 to disable)"
  type        = number
  default     = 7

  validation {
    condition     = var.soft_delete_days >= 0 && var.soft_delete_days <= 365
    error_message = "Soft delete days must be between 0 and 365."
  }
}

variable "container_names" {
  description = "List of container names to create"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
