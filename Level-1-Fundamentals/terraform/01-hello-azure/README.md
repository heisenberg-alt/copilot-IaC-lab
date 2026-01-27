# 🟢 Level 1.1: Hello Azure - Your First Terraform Configuration

## 🎯 Objectives

By the end of this exercise, you will:
- Understand basic Terraform file structure
- Configure the Azure provider
- Create your first Azure resource (Resource Group)
- Run `terraform init`, `plan`, and `apply`

## 📚 Concepts Covered

| Concept | Description |
|---------|-------------|
| **Provider** | Plugin that Terraform uses to interact with Azure |
| **Resource** | Infrastructure object managed by Terraform |
| **terraform init** | Initializes working directory, downloads providers |
| **terraform plan** | Preview changes before applying |
| **terraform apply** | Create/update infrastructure |

## 🤖 Copilot Prompts to Try

Open Copilot Chat and try these prompts:

### Generate Configuration
```
Create a basic Terraform configuration for Azure that:
1. Uses Azure provider version 4.0
2. Creates a resource group named "rg-copilot-lab-dev" in East US
3. Includes proper tags for environment and project
```

### Explain Code
```
Explain what terraform init does and why it's the first command we run
```

### Ask Questions
```
What's the difference between terraform plan and terraform apply?
```

## 📋 Challenge

Your task is to complete the Terraform configuration in `challenge/main.tf`:

1. Configure the Azure provider with required features
2. Create a resource group with:
   - Name: `rg-hello-azure-dev`
   - Location: `eastus`
   - Tags: environment, project, managed_by

## 💡 Hints

<details>
<summary>Hint 1: Provider Block Structure</summary>

```hcl
provider "azurerm" {
  features {}
}
```
</details>

<details>
<summary>Hint 2: Resource Group Syntax</summary>

```hcl
resource "azurerm_resource_group" "example" {
  name     = "resource-group-name"
  location = "region"
}
```
</details>

## ✅ Validation

Run these commands to validate your solution:

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Preview changes
terraform plan

# Apply (optional - creates real resources)
terraform apply
```

## 🧹 Cleanup

```bash
terraform destroy
```

## 📁 Files

```
01-hello-azure/
├── README.md           # This file
├── challenge/
│   └── main.tf         # Complete this file
└── solution/
    └── main.tf         # Reference solution
```
