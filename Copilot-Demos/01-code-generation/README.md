# 🎯 Demo 1: Code Generation

Generate complete Infrastructure as Code from natural language prompts.

## Demo Duration: ~10 minutes

## Prerequisites
- GitHub Copilot extension installed and active
- Copilot Chat panel open

---

## Demo Scenario 1: Generate from Scratch

### Setup
1. Create a new file `demo.tf`
2. Open Copilot Chat

### Prompt to Use

```
Create a Terraform configuration for an Azure web application with:
- Resource group in East US
- App Service Plan (Linux, B1 SKU)  
- Python 3.11 web app
- Application Insights for monitoring
- Storage account for app data
Include proper naming conventions and tags
```

### What to Highlight
- Copilot generates complete, working code
- Follows Azure naming conventions
- Includes best practices (HTTPS, TLS)
- Adds appropriate tags

---

## Demo Scenario 2: Generate from Comments

### Setup
1. Open the file `comment-driven.tf`
2. Position cursor after the comments

### Steps
1. Read the comment aloud
2. Press Enter after the comment
3. Show Copilot's inline suggestions
4. Accept with Tab

### What to Highlight
- Comment-driven development
- Copilot understands context
- Generates appropriate resource types

---

## Demo Scenario 3: Generate Bicep from Description

### Prompt to Use

```
Convert this description to Bicep:
I need a storage account named 'stdemostorage' in eastus with:
- Standard LRS replication
- Hot access tier  
- Blob versioning enabled
- A container named 'data'
```

### What to Highlight
- Copilot knows both Terraform AND Bicep
- Applies correct decorators
- Uses latest API versions

---

## Demo Scenario 4: Generate Tests

### Prompt to Use

```
Generate Terratest code to test this storage module:
- Verify storage account is created
- Check that containers exist
- Validate blob endpoint is accessible
```

### What to Highlight
- Copilot can generate test code
- Understands testing frameworks
- Creates meaningful assertions

---

## Key Talking Points

1. **Speed** - Generate working code in seconds
2. **Accuracy** - Follows Azure best practices
3. **Context Awareness** - Understands the domain
4. **Learning** - Great for discovering new features
5. **Customization** - Adapt generated code to needs

## Common Questions

**Q: Does Copilot always generate correct code?**
A: It generates good starting points that should be reviewed and validated.

**Q: Can it generate for any cloud provider?**
A: Yes - AWS, Azure, GCP, and more.

**Q: Does it use the latest API versions?**
A: Usually, but always verify against current documentation.
