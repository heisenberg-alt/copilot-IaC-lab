# =============================================================================
# Level 2.2: Compute - Solution
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
  tags     = local.common_tags
}

# -----------------------------------------------------------------------------
# Networking
# -----------------------------------------------------------------------------
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.workload}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]
  tags                = local.common_tags
}

resource "azurerm_subnet" "web" {
  name                 = "snet-web"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# NSG for web tier
resource "azurerm_network_security_group" "web" {
  name                = "nsg-web-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Public IPs
# -----------------------------------------------------------------------------
resource "azurerm_public_ip" "web" {
  count               = var.vm_count
  name                = "pip-web-${count.index + 1}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

# -----------------------------------------------------------------------------
# Network Interfaces
# -----------------------------------------------------------------------------
resource "azurerm_network_interface" "web" {
  count               = var.vm_count
  name                = "nic-web-${count.index + 1}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.web.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.web[count.index].id
  }

  tags = local.common_tags
}

# Associate NSG with NICs
resource "azurerm_network_interface_security_group_association" "web" {
  count                     = var.vm_count
  network_interface_id      = azurerm_network_interface.web[count.index].id
  network_security_group_id = azurerm_network_security_group.web.id
}

# -----------------------------------------------------------------------------
# Virtual Machines
# -----------------------------------------------------------------------------
resource "azurerm_linux_virtual_machine" "web" {
  count               = var.vm_count
  name                = "vm-web-${count.index + 1}-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.web[count.index].id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_key
  }

  os_disk {
    name                 = "osdisk-web-${count.index + 1}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  custom_data = base64encode(local.cloud_init)

  tags = local.common_tags
}
