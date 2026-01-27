# =============================================================================
# Hardcoded Values - Refactoring Demo
# =============================================================================
# This code has many hardcoded values.
# Ask Copilot to refactor it to use variables!
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

# Hardcoded resource group
resource "azurerm_resource_group" "main" {
  name     = "rg-myapp-production-eastus"
  location = "eastus"

  tags = {
    environment = "production"
    project     = "myapp"
    cost_center = "12345"
    owner       = "platform-team"
  }
}

# Hardcoded storage account
resource "azurerm_storage_account" "main" {
  name                     = "stmyappprod001"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  access_tier              = "Hot"

  tags = {
    environment = "production"
    project     = "myapp"
    cost_center = "12345"
    owner       = "platform-team"
  }
}

# Hardcoded virtual network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-myapp-production-eastus"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "production"
    project     = "myapp"
    cost_center = "12345"
    owner       = "platform-team"
  }
}

# Hardcoded subnets
resource "azurerm_subnet" "web" {
  name                 = "snet-web"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "app" {
  name                 = "snet-app"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "data" {
  name                 = "snet-data"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.3.0/24"]
}
