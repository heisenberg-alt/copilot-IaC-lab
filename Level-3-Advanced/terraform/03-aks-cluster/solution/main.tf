# =============================================================================
# Level 3.3: AKS Cluster - Solution
# =============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "environment" {
  default = "dev"
}

variable "location" {
  default = "eastus"
}

variable "workload" {
  default = "aks"
}

locals {
  common_tags = {
    environment = var.environment
    project     = var.workload
    managed_by  = "terraform"
  }
}

# -----------------------------------------------------------------------------
# Resource Group
# -----------------------------------------------------------------------------
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.workload}-${var.environment}"
  location = var.location
  tags     = local.common_tags
}

# -----------------------------------------------------------------------------
# Container Registry
# -----------------------------------------------------------------------------
resource "azurerm_container_registry" "main" {
  name                = "acr${var.workload}${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Standard"
  admin_enabled       = false

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# AKS Cluster
# -----------------------------------------------------------------------------
resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-${var.workload}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "aks-${var.workload}-${var.environment}"

  default_node_pool {
    name                = "system"
    node_count          = 2
    vm_size             = "Standard_DS2_v2"
    os_disk_size_gb     = 30
    type                = "VirtualMachineScaleSets"
    auto_scaling_enabled = true
    min_count           = 1
    max_count           = 3
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  tags = local.common_tags
}

# User node pool
resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "user"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = "Standard_DS2_v2"
  node_count            = 2
  auto_scaling_enabled  = true
  min_count             = 1
  max_count             = 5

  node_labels = {
    "workload" = "user"
  }

  tags = local.common_tags
}

# ACR Pull permission for AKS
resource "azurerm_role_assignment" "aks_acr" {
  principal_id                     = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.main.id
  skip_service_principal_aad_check = true
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------
output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.main.name
}

output "aks_cluster_id" {
  value = azurerm_kubernetes_cluster.main.id
}

output "acr_login_server" {
  value = azurerm_container_registry.main.login_server
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive = true
}

output "get_credentials_command" {
  value = "az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.main.name}"
}
