# 🟢 Level 1.1: Hello Azure - Your First Bicep Template

## 🎯 Objectives

By the end of this exercise, you will:
- Understand basic Bicep file structure
- Create your first Azure resource (Resource Group)
- Run `az deployment` commands
- Understand the difference between Bicep and ARM

## 📚 Concepts Covered

| Concept | Description |
|---------|-------------|
| **resource** | Declaration of an Azure resource |
| **targetScope** | Deployment scope (subscription, resourceGroup, etc.) |
| **az deployment** | Azure CLI command to deploy Bicep |
| **what-if** | Preview deployment changes |

## 🤖 Copilot Prompts to Try

### Generate Configuration
```
Create a Bicep template that deploys a resource group named "rg-copilot-lab-dev" 
in East US with tags for environment and project
```

### Explain Bicep
```
What's the difference between Bicep and ARM templates?
Why should I use Bicep?
```

### Understand Scopes
```
Explain Bicep targetScope and when to use subscription vs resourceGroup scope
```

## 📋 Challenge

Complete the Bicep template in `challenge/main.bicep`:

1. Set the target scope to subscription
2. Create a resource group with:
   - Name: `rg-hello-azure-dev`
   - Location: `eastus`
   - Tags: environment, project, managed_by

## 💡 Hints

<details>
<summary>Hint 1: Target Scope</summary>

```bicep
targetScope = 'subscription'
```
</details>

<details>
<summary>Hint 2: Resource Group Syntax</summary>

```bicep
resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'resource-group-name'
  location: 'region'
  tags: {
    key: 'value'
  }
}
```
</details>

## ✅ Validation

```bash
# Login to Azure
az login

# Preview deployment (what-if)
az deployment sub what-if \
  --location eastus \
  --template-file main.bicep

# Deploy
az deployment sub create \
  --location eastus \
  --template-file main.bicep
```

## 🧹 Cleanup

```bash
az group delete --name rg-hello-azure-dev --yes
```

## 📁 Files

```
01-hello-azure/
├── README.md           # This file
├── challenge/
│   └── main.bicep      # Complete this file
└── solution/
    └── main.bicep      # Reference solution
```
