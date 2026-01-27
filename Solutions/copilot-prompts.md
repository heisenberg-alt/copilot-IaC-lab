# Effective Copilot Prompts for IaC

## General Principles

1. **Be Specific** - Include resource types, names, and requirements
2. **Provide Context** - Mention environment, region, project
3. **Request Best Practices** - Ask for security and optimization
4. **Iterate** - Refine based on initial output

---

## Resource Creation Prompts

### Basic Resources
```
Create a Terraform resource group named "rg-demo-dev" in East US with 
environment and project tags
```

### With Requirements
```
Create an Azure Storage Account with:
- Name: stdemostorage
- SKU: Standard_LRS
- Enable blob versioning
- Enable soft delete (30 days)
- HTTPS only
- TLS 1.2 minimum
Include appropriate tags
```

### Complex Resources
```
Create a Bicep template for an AKS cluster with:
- System node pool: 2 nodes, Standard_D4s_v3
- User node pool: 0-10 nodes with autoscaling
- Azure CNI networking
- Managed identity
- Azure Policy addon enabled
- Log Analytics integration
```

---

## Module Creation Prompts

```
Create a reusable Terraform module for Azure Storage with:
- Configurable name prefix
- Configurable replication type
- Optional containers parameter
- Outputs for ID, name, and primary endpoint
Include variables.tf, outputs.tf, and README.md
```

---

## Code Explanation Prompts

```
Explain what this dynamic block does and how the for_each works
```

```
What's the difference between count and for_each?
When should I use each approach?
```

```
Explain the Bicep deployment scopes: resourceGroup, subscription, 
managementGroup, and tenant
```

---

## Error Fixing Prompts

```
Fix the errors in this Terraform file
```

```
This deployment is failing with "resource already exists". 
How do I import it into state?
```

```
Why is this Bicep template failing with "InvalidTemplateDeployment"?
```

---

## Refactoring Prompts

```
Refactor this code to use variables instead of hardcoded values.
Add descriptions and validation to all variables.
```

```
Convert this Terraform configuration from using count to for_each
```

```
Extract this storage configuration into a reusable module
```

```
Convert this Terraform to Bicep (or vice versa)
```

---

## Best Practices Prompts

```
Review this code for Azure security best practices:
- Enable encryption
- Use managed identities
- Configure network rules
- Add diagnostic settings
```

```
What tags should I add to Azure resources for cost management 
and governance?
```

```
How should I structure my Terraform project for a multi-environment 
deployment?
```

---

## CI/CD Prompts

```
Create a GitHub Actions workflow for Terraform that:
- Runs terraform fmt and validate on PRs
- Creates a plan and posts to PR comments
- Applies on merge to main
- Uses OIDC for Azure authentication
```

```
Generate Azure DevOps pipeline YAML for Bicep deployments 
with what-if preview
```

---

## Documentation Prompts

```
Generate a README.md for this Terraform module including:
- Description
- Requirements
- Usage example
- Inputs table
- Outputs table
```

---

## Advanced Prompts

### Multi-Resource
```
Create a complete web application infrastructure with:
- Resource group
- Virtual network with 3 subnets
- App Service Plan (Linux, B1)
- Python web app
- Azure SQL Database
- Key Vault for secrets
- Application Insights
Use managed identity for all service connections
```

### Troubleshooting
```
My Terraform state shows the resource exists but Azure shows 
it doesn't. How do I fix the state drift?
```

### Architecture
```
What's the best practice for organizing Terraform for:
- Multiple environments (dev/staging/prod)
- Multiple regions
- Shared and application-specific resources
```

---

## Chat Commands Reference

| Command | Use Case |
|---------|----------|
| `/explain` | Understand selected code |
| `/fix` | Fix errors in selection |
| `/tests` | Generate tests |
| `@workspace` | Search entire workspace |
| `/clear` | Clear chat history |
