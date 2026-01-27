# =============================================================================
# Level 2.1: Networking - Solution
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

# -----------------------------------------------------------------------------
# Resource Group
# -----------------------------------------------------------------------------
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.workload}-${var.environment}"
  location = var.location

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Virtual Network
# -----------------------------------------------------------------------------
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.workload}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = var.vnet_address_space

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Subnets (using for_each)
# -----------------------------------------------------------------------------
resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  name                 = "snet-${each.key}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [each.value.address_prefix]

  service_endpoints = lookup(each.value, "service_endpoints", [])
}

# -----------------------------------------------------------------------------
# Network Security Groups
# -----------------------------------------------------------------------------
resource "azurerm_network_security_group" "nsgs" {
  for_each = var.subnets

  name                = "nsg-${each.key}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# NSG Rules
# -----------------------------------------------------------------------------

# Web tier - Allow HTTP/HTTPS from Internet
resource "azurerm_network_security_rule" "web_http" {
  name                        = "Allow-HTTP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.nsgs["web"].name
}

resource "azurerm_network_security_rule" "web_https" {
  name                        = "Allow-HTTPS"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.nsgs["web"].name
}

# App tier - Allow 8080 from Web subnet
resource "azurerm_network_security_rule" "app_from_web" {
  name                        = "Allow-From-Web"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8080"
  source_address_prefix       = var.subnets["web"].address_prefix
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.nsgs["app"].name
}

# DB tier - Allow 1433 from App subnet
resource "azurerm_network_security_rule" "db_from_app" {
  name                        = "Allow-From-App"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "1433"
  source_address_prefix       = var.subnets["app"].address_prefix
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.nsgs["db"].name
}

# -----------------------------------------------------------------------------
# NSG Associations
# -----------------------------------------------------------------------------
resource "azurerm_subnet_network_security_group_association" "associations" {
  for_each = var.subnets

  subnet_id                 = azurerm_subnet.subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.nsgs[each.key].id
}
