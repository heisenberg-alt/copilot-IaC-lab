# Storage Module

Creates an Azure Storage Account with optional blob containers.

## Usage

```hcl
module "storage" {
  source = "./modules/storage"

  storage_account_name = "stmyappdev001"
  resource_group_name  = azurerm_resource_group.main.name
  location             = azurerm_resource_group.main.location

  account_tier      = "Standard"
  replication_type  = "LRS"
  access_tier       = "Hot"
  enable_versioning = true
  soft_delete_days  = 7

  container_names = ["data", "logs", "backups"]

  tags = {
    environment = "dev"
    project     = "myapp"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| storage_account_name | Globally unique storage account name | string | - | yes |
| resource_group_name | Resource group name | string | - | yes |
| location | Azure region | string | - | yes |
| account_tier | Standard or Premium | string | "Standard" | no |
| replication_type | LRS, GRS, etc. | string | "LRS" | no |
| access_tier | Hot or Cool | string | "Hot" | no |
| enable_versioning | Enable blob versioning | bool | true | no |
| soft_delete_days | Soft delete retention days | number | 7 | no |
| container_names | List of containers to create | list(string) | [] | no |
| tags | Resource tags | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| id | Storage account ID |
| name | Storage account name |
| primary_blob_endpoint | Primary blob endpoint URL |
| primary_connection_string | Connection string (sensitive) |
| primary_access_key | Access key (sensitive) |
| container_ids | Map of container names to IDs |
