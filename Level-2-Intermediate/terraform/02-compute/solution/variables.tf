# =============================================================================
# Level 2.2: Variables - Solution
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
  default     = "compute"
}

variable "vm_count" {
  description = "Number of VMs to create"
  type        = number
  default     = 2

  validation {
    condition     = var.vm_count >= 1 && var.vm_count <= 10
    error_message = "VM count must be between 1 and 10."
  }
}

variable "vm_size" {
  description = "Size of the VMs"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Admin username for VMs"
  type        = string
  default     = "azureadmin"
}

variable "admin_ssh_key" {
  description = "SSH public key for VM authentication"
  type        = string
}

locals {
  common_tags = {
    environment = var.environment
    project     = var.workload
    managed_by  = "terraform"
  }

  cloud_init = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    echo "<h1>Hello from $(hostname)</h1>" > /var/www/html/index.html
    systemctl start nginx
    systemctl enable nginx
  EOF
}
