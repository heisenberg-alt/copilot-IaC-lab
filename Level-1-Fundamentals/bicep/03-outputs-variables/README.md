# 🟢 Level 1.3: Outputs and Variables

## 🎯 Objectives

By the end of this exercise, you will:
- Understand variables and when to use them
- Create meaningful outputs with descriptions
- Use expressions and string interpolation
- Reference existing resources

## 📚 Concepts Covered

| Concept | Description |
|---------|-------------|
| **var** | Named expressions for reuse |
| **output** | Return values from a template |
| **@description** | Documentation for outputs |
| **existing** | Reference existing Azure resources |
| **string interpolation** | `'${variable}-suffix'` syntax |

## 🤖 Copilot Prompts to Try

### Generate Variables
```
Create Bicep variables for:
- Naming convention: {resource}-{workload}-{env}-{region}
- Common tags object
- Array of storage container names
```

### Generate Outputs
```
Create comprehensive Bicep outputs for a storage account including:
- Resource IDs
- Endpoints
- Connection strings
Include @description decorators for all outputs
```

### Explain Concepts
```
What's the difference between parameters and variables in Bicep?
When should I use each?
```

## 📋 Challenge

Create a configuration with:

1. **Storage Account** with multiple containers
2. **Key Vault** to store secrets
3. **Comprehensive Variables** for naming and tags
4. **Meaningful Outputs** for all resources

### Requirements

#### Variables
- `namePrefix`: Combination of workload, environment, and region
- `commonTags`: Standard tags for all resources
- `containerNames`: Array with ["data", "logs", "backups"]

#### Outputs
- All resource IDs
- Storage account blob endpoint
- Key Vault URI
- Container names array

## 💡 Hints

<details>
<summary>Hint 1: Variables Pattern</summary>

```bicep
var namePrefix = '${workload}-${environment}-${location}'

var commonTags = {
  environment: environment
  project: workload
  managed_by: 'bicep'
}
```
</details>

<details>
<summary>Hint 2: Creating Multiple Containers</summary>

```bicep
var containerNames = ['data', 'logs', 'backups']

resource containers 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = [
  for name in containerNames: {
    parent: blobServices
    name: name
    properties: {
      publicAccess: 'None'
    }
  }
]
```
</details>

<details>
<summary>Hint 3: Output with Description</summary>

```bicep
@description('The URI of the Key Vault')
output keyVaultUri string = keyVault.properties.vaultUri
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

# Deploy and show outputs
az deployment group create \
  --resource-group rg-iaclab-dev \
  --template-file main.bicep \
  --parameters main.bicepparam \
  --query properties.outputs
```

## 📁 Files

```
03-outputs-variables/
├── README.md
├── challenge/
│   ├── main.bicep           # Complete this
│   └── main.bicepparam
└── solution/
    ├── main.bicep
    └── main.bicepparam
```
