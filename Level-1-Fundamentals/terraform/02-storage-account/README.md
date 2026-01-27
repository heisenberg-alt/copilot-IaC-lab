# 🟢 Level 1.2: Storage Account with Variables

## 🎯 Objectives

By the end of this exercise, you will:
- Define and use input variables
- Understand variable types (string, number, bool)
- Use variable validation
- Create an Azure Storage Account

## 📚 Concepts Covered

| Concept | Description |
|---------|-------------|
| **variable** | Input parameter for Terraform configuration |
| **type** | Data type constraint (string, number, bool, list, map) |
| **default** | Default value if not provided |
| **validation** | Custom validation rules for variables |
| **description** | Documentation for the variable |

## 🤖 Copilot Prompts to Try

### Generate Variables
```
Create Terraform variables for:
- environment (dev/staging/prod with validation)
- location (Azure region with default eastus)
- storage_account_name (with length validation 3-24 chars)
```

### Generate Storage Account
```
Create an Azure storage account with:
- Standard_LRS replication
- Hot access tier
- Blob versioning enabled
- HTTPS only
```

### Explain Validation
```
Explain how Terraform variable validation blocks work and when to use them
```

## 📋 Challenge

Complete the configuration in the `challenge/` folder:

1. **variables.tf**: Define variables with proper types, descriptions, and validation
2. **main.tf**: Create a storage account using the variables

### Requirements

| Variable | Type | Validation | Default |
|----------|------|------------|---------|
| environment | string | dev, staging, prod | dev |
| location | string | - | eastus |
| project_name | string | min 3, max 20 chars | - |

### Storage Account Requirements

- Account tier: Standard
- Replication: LRS
- Access tier: Hot
- HTTPS traffic only: true
- Blob versioning: enabled

## 💡 Hints

<details>
<summary>Hint 1: Variable with Validation</summary>

```hcl
variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
```
</details>

<details>
<summary>Hint 2: Storage Account Naming</summary>

Storage account names must be:
- 3-24 characters
- Lowercase letters and numbers only
- Globally unique

```hcl
locals {
  storage_name = "st${replace(var.project_name, "-", "")}${var.environment}"
}
```
</details>

## ✅ Validation

```bash
cd challenge

# Initialize
terraform init

# Validate
terraform validate

# Plan with variables
terraform plan -var="project_name=myapp"

# Or use a tfvars file
terraform plan -var-file="terraform.tfvars"
```

## 📁 Files

```
02-storage-account/
├── README.md
├── challenge/
│   ├── main.tf              # Complete this
│   ├── variables.tf         # Complete this
│   └── terraform.tfvars     # Example values
└── solution/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── terraform.tfvars.example
```
