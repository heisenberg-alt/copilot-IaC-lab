# 🟢 Level 1.2: Storage Account with Parameters

## 🎯 Objectives

By the end of this exercise, you will:
- Define and use parameters with decorators
- Understand Bicep decorators (@description, @allowed, @minLength)
- Create an Azure Storage Account
- Use parameter files (.bicepparam)

## 📚 Concepts Covered

| Concept | Description |
|---------|-------------|
| **param** | Input parameter for Bicep template |
| **@description** | Documentation decorator |
| **@allowed** | Enumeration constraint |
| **@minLength/@maxLength** | String length constraints |
| **@secure** | Mark parameter as secret |
| **.bicepparam** | Parameter file format |

## 🤖 Copilot Prompts to Try

### Generate Parameters
```
Create Bicep parameters for:
- environment (dev/staging/prod with @allowed decorator)
- location (Azure region with default eastus)
- storageAccountName (with @minLength and @maxLength decorators)
Include @description for all parameters
```

### Generate Storage Account
```
Create a Bicep resource for Azure storage account with:
- Standard_LRS SKU
- Hot access tier
- Blob versioning enabled
- HTTPS only
```

### Explain Decorators
```
Explain all available Bicep parameter decorators and when to use each one
```

## 📋 Challenge

Complete the configuration in the `challenge/` folder:

1. **main.bicep**: Define parameters and create resources
2. **main.bicepparam**: Create parameter file

### Requirements

| Parameter | Decorator | Default |
|-----------|-----------|---------|
| environment | @allowed(['dev', 'staging', 'prod']) | dev |
| location | @description | eastus |
| projectName | @minLength(3), @maxLength(20) | - |

### Storage Account Requirements

- SKU: Standard_LRS
- Kind: StorageV2
- Access tier: Hot
- HTTPS only: true
- Minimum TLS: 1.2
- Blob versioning: enabled

## 💡 Hints

<details>
<summary>Hint 1: Parameter with Decorators</summary>

```bicep
@description('The deployment environment')
@allowed(['dev', 'staging', 'prod'])
param environment string = 'dev'
```
</details>

<details>
<summary>Hint 2: Storage Account Naming</summary>

```bicep
// Storage names: 3-24 chars, lowercase letters and numbers only
var storageAccountName = 'st${replace(projectName, '-', '')}${environment}'
```
</details>

<details>
<summary>Hint 3: Parameter File (.bicepparam)</summary>

```bicep
using './main.bicep'

param environment = 'dev'
param location = 'eastus'
param projectName = 'myapp'
```
</details>

## ✅ Validation

```bash
cd challenge

# Preview deployment
az deployment group what-if \
  --resource-group rg-iaclab-dev \
  --template-file main.bicep \
  --parameters main.bicepparam

# Deploy
az deployment group create \
  --resource-group rg-iaclab-dev \
  --template-file main.bicep \
  --parameters main.bicepparam
```

## 📁 Files

```
02-storage-account/
├── README.md
├── challenge/
│   ├── main.bicep           # Complete this
│   └── main.bicepparam      # Complete this
└── solution/
    ├── main.bicep
    └── main.bicepparam
```
