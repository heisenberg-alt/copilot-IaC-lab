# =============================================================================
# Complex Code for Explanation Demo
# =============================================================================
# Select sections of this code and ask Copilot to explain them!
# =============================================================================

variable "network_rules" {
  description = "Network rules for storage account"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = []
}

variable "subnets" {
  type = map(object({
    address_prefix    = string
    service_endpoints = optional(list(string), [])
    delegation = optional(object({
      name         = string
      service_name = string
      actions      = list(string)
    }))
  }))
}

# Complex Dynamic Block - Select this and ask Copilot to explain
resource "azurerm_network_security_group" "example" {
  name                = "nsg-example"
  location            = "eastus"
  resource_group_name = "rg-example"

  dynamic "security_rule" {
    for_each = var.network_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}

# Complex for_each with conditionals - Select this for explanation
resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  name                 = "snet-${each.key}"
  resource_group_name  = "rg-example"
  virtual_network_name = "vnet-example"
  address_prefixes     = [each.value.address_prefix]
  service_endpoints    = each.value.service_endpoints

  dynamic "delegation" {
    for_each = each.value.delegation != null ? [each.value.delegation] : []
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_name
        actions = delegation.value.actions
      }
    }
  }
}

# Complex expression - Select this for explanation
locals {
  flattened_rules = flatten([
    for subnet_key, subnet in var.subnets : [
      for rule in lookup(subnet, "nsg_rules", []) : {
        subnet_key = subnet_key
        rule_name  = rule.name
        rule       = rule
      }
    ]
  ])

  rule_map = {
    for item in local.flattened_rules :
    "${item.subnet_key}-${item.rule_name}" => item.rule
  }
}
