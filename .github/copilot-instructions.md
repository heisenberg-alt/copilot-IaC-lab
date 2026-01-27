# GitHub Copilot Instructions for IaC Lab

This file customizes GitHub Copilot's behavior for Infrastructure as Code development in this repository.

## General Guidelines

- Always generate production-ready, secure code
- Include comprehensive comments explaining complex logic
- Follow Azure Well-Architected Framework principles
- Use consistent naming conventions throughout

## Terraform Guidelines

### Provider Configuration
- Use Azure provider version >= 4.0
- Always include `required_providers` block with version constraints
- Use `required_version` for Terraform version constraints
- Configure backend for state management in non-demo scenarios

```hcl
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}
```

### Variables
- Use variables for ALL configurable values (no hardcoding)
- Include `description` for every variable
- Include `type` constraints
- Use `validation` blocks for input validation
- Provide sensible `default` values where appropriate

```hcl
variable "environment" {
  description = "The deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

### Outputs
- Include `description` for every output
- Output resource IDs, names, and connection strings
- Use `sensitive = true` for secrets

### Naming Convention
Follow this pattern: `{resource-prefix}-{workload}-{environment}-{region}-{instance}`

```hcl
locals {
  name_prefix = "${var.workload}-${var.environment}-${var.location}"
}
```

### Tags
Always include these tags on all resources:

```hcl
locals {
  common_tags = {
    environment = var.environment
    project     = var.project_name
    managed_by  = "terraform"
    created_by  = "copilot-iac-lab"
  }
}
```

## Bicep Guidelines

### API Versions
- Use the latest stable API versions
- Reference: https://docs.microsoft.com/azure/templates/

### Parameters
- Use `@description()` decorator on ALL parameters
- Use `@allowed()` for enumerated values
- Use `@minLength()` / `@maxLength()` for strings
- Use `@minValue()` / `@maxValue()` for numbers
- Use `@secure()` for secrets
- Use camelCase for parameter names

```bicep
@description('The deployment environment')
@allowed(['dev', 'staging', 'prod'])
param environment string = 'dev'

@description('The administrator password')
@secure()
param adminPassword string
```

### Variables
- Use camelCase for variable names
- Use variables for computed values and name construction

```bicep
var namePrefix = '${workload}-${environment}-${location}'
var resourceGroupName = 'rg-${namePrefix}'
```

### Outputs
- Include `@description()` decorator
- Output resource IDs, names, and endpoints

```bicep
@description('The resource ID of the storage account')
output storageAccountId string = storageAccount.id
```

### Modules
- One resource type per module when possible
- Use descriptive module names
- Pass only required parameters

### Tags
Always include these tags:

```bicep
var commonTags = {
  environment: environment
  project: projectName
  managed_by: 'bicep'
  created_by: 'copilot-iac-lab'
}
```

## Security Guidelines

### Secrets Management
- NEVER hardcode secrets, passwords, or keys
- Use Azure Key Vault for secret storage
- Use managed identities where possible
- Mark sensitive outputs appropriately

### Network Security
- Use private endpoints for PaaS services
- Configure NSG rules with least privilege
- Enable diagnostic logging

### Identity
- Prefer managed identities over service principals
- Use RBAC with least privilege principle
- Avoid using Owner role

## Code Organization

### File Structure for Terraform
```
module/
├── main.tf           # Primary resources
├── variables.tf      # Input variables
├── outputs.tf        # Output values
├── locals.tf         # Local values
├── providers.tf      # Provider configuration
├── versions.tf       # Version constraints
├── data.tf           # Data sources
└── README.md         # Documentation
```

### File Structure for Bicep
```
module/
├── main.bicep        # Primary template
├── main.bicepparam   # Parameter file
├── modules/          # Child modules
└── README.md         # Documentation
```

## Documentation

When generating code, include:
1. File header comment with purpose
2. Inline comments for complex logic
3. README.md with usage instructions
4. Example tfvars/bicepparam files

## Error Handling

- Use `lifecycle` blocks in Terraform for resource management
- Use `dependsOn` explicitly when implicit dependencies aren't sufficient
- Include retry logic for eventual consistency issues
