# 🟠 Level 3.1: Terraform Modules

## 🎯 Objectives

By the end of this exercise, you will:
- Create reusable Terraform modules
- Understand module structure and best practices
- Use module inputs, outputs, and versioning
- Call modules from root configuration

## 📚 Concepts Covered

| Concept | Description |
|---------|-------------|
| **Module** | Reusable container for resources |
| **Root Module** | Main configuration calling other modules |
| **Child Module** | Called by root or other modules |
| **Module Sources** | Local, Git, Registry |

## 🤖 Copilot Prompts to Try

### Create a Module
```
Create a Terraform module for Azure storage account that:
- Accepts variables for name, location, replication type
- Creates storage account with containers
- Outputs account ID, name, and primary endpoint
- Follows module best practices
```

### Explain Module Structure
```
What's the recommended file structure for a Terraform module?
What should go in each file?
```

## 📋 Challenge

Create a modular infrastructure:

1. **Storage Module** - Reusable storage account
2. **Networking Module** - VNet with configurable subnets
3. **Root Module** - Calls both modules

### Module Requirements

Each module should have:
- variables.tf with descriptions and validation
- outputs.tf with all relevant outputs
- README.md with usage examples
- Examples folder with sample usage

## 📁 Files

```
01-modules/
├── README.md
├── modules/
│   ├── storage/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   └── networking/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── README.md
├── challenge/
│   └── main.tf          # Call modules here
└── solution/
    └── main.tf
```
