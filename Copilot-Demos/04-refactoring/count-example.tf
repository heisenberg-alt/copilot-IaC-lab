# =============================================================================
# Count Example - Refactoring Demo
# =============================================================================
# This code uses count. Ask Copilot to refactor to for_each!
# =============================================================================

variable "vm_count" {
  default = 3
}

resource "azurerm_public_ip" "vms" {
  count               = var.vm_count
  name                = "pip-vm-${count.index + 1}"
  location            = "eastus"
  resource_group_name = "rg-demo"
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "vms" {
  count               = var.vm_count
  name                = "nic-vm-${count.index + 1}"
  location            = "eastus"
  resource_group_name = "rg-demo"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = "/subscriptions/.../subnets/default"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vms[count.index].id
  }
}

resource "azurerm_linux_virtual_machine" "vms" {
  count               = var.vm_count
  name                = "vm-${count.index + 1}"
  resource_group_name = "rg-demo"
  location            = "eastus"
  size                = "Standard_B2s"
  admin_username      = "adminuser"

  network_interface_ids = [
    azurerm_network_interface.vms[count.index].id
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

output "vm_public_ips" {
  value = azurerm_public_ip.vms[*].ip_address
}
