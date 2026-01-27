# Networking Module

Creates an Azure Virtual Network with subnets and optional NSGs.

## Usage

```hcl
module "networking" {
  source = "./modules/networking"

  vnet_name           = "vnet-myapp-dev"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = ["10.0.0.0/16"]

  subnets = {
    "snet-web" = {
      address_prefix    = "10.0.1.0/24"
      service_endpoints = ["Microsoft.Storage"]
    }
    "snet-app" = {
      address_prefix = "10.0.2.0/24"
      delegation = {
        name         = "webapp"
        service_name = "Microsoft.Web/serverFarms"
        actions      = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
  }

  create_nsg = true

  tags = {
    environment = "dev"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| vnet_name | VNet name | string | - | yes |
| resource_group_name | Resource group name | string | - | yes |
| location | Azure region | string | - | yes |
| address_space | VNet address space | list(string) | ["10.0.0.0/16"] | no |
| subnets | Subnet configurations | map(object) | {} | no |
| create_nsg | Create NSGs | bool | true | no |
| tags | Resource tags | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| vnet_id | Virtual network ID |
| vnet_name | Virtual network name |
| subnet_ids | Map of subnet names to IDs |
| nsg_ids | Map of NSG names to IDs |
