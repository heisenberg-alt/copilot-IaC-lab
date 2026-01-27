# 🎯 Demo 5: GitHub CLI Integration

Use `gh copilot` commands in the terminal.

## Demo Duration: ~5 minutes

## Prerequisites
```bash
# Ensure GitHub CLI and Copilot extension are installed
gh extension install github/gh-copilot
gh auth login
```

---

## Demo Scenario 1: Explain Commands

### Commands to Demo

```bash
# Explain Terraform commands
gh copilot explain "terraform state mv"

gh copilot explain "terraform import azurerm_resource_group.example /subscriptions/.../resourceGroups/mygroup"

gh copilot explain "terraform workspace select prod"
```

### What to Highlight
- Get explanations without leaving terminal
- Understand complex command syntax
- Learn flags and options

---

## Demo Scenario 2: Get Suggestions

### Commands to Demo

```bash
# Ask for suggestions
gh copilot suggest "how to import an existing Azure storage account into Terraform"

gh copilot suggest "terraform command to see what resources are in state"

gh copilot suggest "Azure CLI command to list all resource groups"
```

### What to Highlight
- Get command suggestions naturally
- Choose from multiple options
- Copy directly to clipboard

---

## Demo Scenario 3: Explain Azure CLI Commands

### Commands to Demo

```bash
gh copilot explain "az deployment group what-if"

gh copilot explain "az bicep decompile"

gh copilot explain "az aks get-credentials"
```

### What to Highlight
- Works with Azure CLI too
- Explains parameters and options
- Shows practical examples

---

## Demo Scenario 4: Troubleshooting

### Commands to Demo

```bash
gh copilot suggest "Terraform error: resource already exists, how to fix"

gh copilot suggest "Azure deployment failed with quota exceeded"
```

### What to Highlight
- Get troubleshooting help
- Understand error messages
- Find solutions quickly

---

## Interactive Demo Script

Run this sequence for a complete demo:

```bash
# 1. Show help
gh copilot --help

# 2. Explain a Terraform concept
gh copilot explain "terraform plan -out=tfplan"

# 3. Get a suggestion
gh copilot suggest "create a new Terraform workspace for staging"

# 4. Explain Azure command
gh copilot explain "az deployment sub create --location eastus --template-file main.bicep"
```

---

## Tips for Demo

1. **Type slowly** - Let audience see the commands
2. **Read responses aloud** - Explain what Copilot said
3. **Try variations** - Show it handles different phrasings
4. **Show errors** - It handles mistakes gracefully
