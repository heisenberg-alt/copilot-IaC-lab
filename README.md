<div align="center">

# GitHub Copilot IaC Lab

**Learn Infrastructure as Code with AI-powered assistance**

[![Terraform](https://img.shields.io/badge/Terraform-7B42BC?logo=terraform&logoColor=white)](https://terraform.io)
[![Bicep](https://img.shields.io/badge/Bicep-0078D4?logo=microsoft-azure&logoColor=white)](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
[![Copilot](https://img.shields.io/badge/GitHub_Copilot-000?logo=github&logoColor=white)](https://github.com/features/copilot)
[![Go](https://img.shields.io/badge/Go-00ADD8?logo=go&logoColor=white)](https://go.dev)

</div>

---

## What's Inside

```
Level 1-4          →  24 progressive IaC challenges (Terraform + Bicep)
Copilot Demos      →  5 AI-assisted coding scenarios
Copilot SDK        →  4 custom extension demos (MCP, Skillset, Agent, Cost API)
Interactive CLI    →  Gamified terminal with XP tracking
```

---

## Quick Start

```bash
# Clone
git clone https://github.com/heisenberg-alt/copilot-IaC-lab.git
cd copilot-IaC-lab

# Run interactive CLI
.\cli\iac-lab.ps1        # Windows
./cli/iac-lab.sh         # Mac/Linux
```

---

## Learning Path

| Level | Focus | What You'll Build |
|:-----:|-------|-------------------|
| 1 | Fundamentals | Resource groups, storage accounts, outputs |
| 2 | Intermediate | VNets, VMs, App Services |
| 3 | Advanced | Modules, remote state, AKS |
| 4 | Enterprise | Multi-region, policy-as-code, CI/CD |

Each challenge has: `challenge/` → `solution/` → `README.md` with Copilot prompts

---

## Copilot SDK Demos

Build your own Copilot-powered tools:

| Demo | Port | Description |
|------|:----:|-------------|
| [MCP Server](Copilot-SDK/01-mcp-servers/) | - | VS Code Copilot Chat tools |
| [IaC Skillset](Copilot-SDK/02-iac-skillset/) | 3000 | Validate / Generate / Explain |
| [Policy Agent](Copilot-SDK/03-policy-agent/) | 8081 | Azure Policy compliance |
| [Cost Estimator](Copilot-SDK/04-cost-estimator/) | 8082 | Azure Retail Prices API |

```bash
# Run any agent
cd Copilot-SDK/03-policy-agent
go build && ./policy-agent
```

---

## Prerequisites

| Tool | Install |
|------|---------|
| Azure CLI | `winget install Microsoft.AzureCLI` |
| Terraform | `winget install Hashicorp.Terraform` |
| Bicep | `az bicep install` |
| Go 1.21+ | [go.dev/dl](https://go.dev/dl) |
| GitHub CLI | `winget install GitHub.cli` |

**VS Code Extensions:** Copilot, Copilot Chat, Terraform, Bicep

---

## Copilot Prompts

```
# Generate
"Create Azure storage account with private endpoint and blob versioning"

# Refactor  
"Convert this to use for_each instead of count"

# Explain
/explain selected code

# Fix
/fix the error in this configuration
```

---

## Structure

```
copilot-IaC-lab/
├── Level-1-Fundamentals/     # 6 challenges
├── Level-2-Intermediate/     # 6 challenges  
├── Level-3-Advanced/         # 6 challenges
├── Level-4-Enterprise/       # 6 challenges
├── Copilot-Demos/            # 5 demo scenarios
├── Copilot-SDK/              # 4 extension demos
├── Solutions/                # Reference patterns
└── cli/                      # Interactive CLI
```

---

<div align="center">

**[Copilot-SDK](Copilot-SDK/)** · **[Demos](Copilot-Demos/)** · **[Solutions](Solutions/)**

MIT License

</div>
