# 🟢 Level 1.3: Outputs and Locals

## 🎯 Objectives

By the end of this exercise, you will:
- Understand local values and when to use them
- Create meaningful outputs
- Use sensitive outputs for secrets
- Chain resources using outputs

## 📚 Concepts Covered

| Concept | Description |
|---------|-------------|
| **locals** | Named expressions for reuse within a module |
| **output** | Return values from a Terraform module |
| **sensitive** | Mark output as sensitive (hidden in logs) |
| **depends_on** | Explicit dependency declaration |

## 🤖 Copilot Prompts to Try

### Generate Locals
```
Create Terraform locals for:
- Naming convention: {resource}-{workload}-{env}-{region}
- Common tags map
- Computed values for storage container names
```

### Generate Outputs
```
Create comprehensive outputs for a storage account including:
- Resource IDs
- Connection strings (marked sensitive)
- Primary endpoints
- Include descriptions for all outputs
```

### Explain Concepts
```
What's the difference between variables and locals in Terraform?
When should I use each?
```

## 📋 Challenge

Create a configuration with:

1. **Resource Group** with proper naming
2. **Storage Account** with multiple containers
3. **Key Vault** to store the storage account key
4. **Comprehensive Outputs** for all resources

### Requirements

#### Locals
- `name_prefix`: Combination of workload, environment, and region
- `common_tags`: Standard tags for all resources
- `container_names`: List of container names ["data", "logs", "backups"]

#### Outputs
- All resource IDs
- Storage account connection string (sensitive)
- Key Vault URI
- Container URLs

## 💡 Hints

<details>
<summary>Hint 1: Locals Block Pattern</summary>

```hcl
locals {
  name_prefix = "${var.workload}-${var.environment}-${var.location}"
  
  common_tags = {
    environment = var.environment
    project     = var.workload
    managed_by  = "terraform"
  }
}
```
</details>

<details>
<summary>Hint 2: Sensitive Output</summary>

```hcl
output "connection_string" {
  description = "Storage account connection string"
  value       = azurerm_storage_account.main.primary_connection_string
  sensitive   = true
}
```
</details>

<details>
<summary>Hint 3: Creating Multiple Containers</summary>

```hcl
resource "azurerm_storage_container" "containers" {
  for_each              = toset(local.container_names)
  name                  = each.value
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}
```
</details>

## ✅ Validation

```bash
cd challenge
terraform init
terraform validate
terraform plan

# View outputs after apply
terraform output
terraform output -json
terraform output storage_connection_string  # Will show (sensitive)
```

## 📁 Files

```
03-outputs-locals/
├── README.md
├── challenge/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf       # Complete this
│   └── locals.tf        # Complete this
└── solution/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── locals.tf
```
