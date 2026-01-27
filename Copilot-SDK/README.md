# 🤖 GitHub Copilot SDK & Extensions Lab

> **Build Custom AI Assistants for Infrastructure as Code**

This section demonstrates how to extend GitHub Copilot's capabilities using the official SDK, MCP Servers, Skillsets, and Agents—all implemented in **Go**.

> 📖 **SDK Reference:** See [GITHUB-COPILOT-SDK.md](./GITHUB-COPILOT-SDK.md) for complete API documentation, code examples, and version information.

```
   ██████╗ ██████╗ ██████╗ ██╗██╗      ██████╗ ████████╗    ███████╗██████╗ ██╗  ██╗
  ██╔════╝██╔═══██╗██╔══██╗██║██║     ██╔═══██╗╚══██╔══╝    ██╔════╝██╔══██╗██║ ██╔╝
  ██║     ██║   ██║██████╔╝██║██║     ██║   ██║   ██║       ███████╗██║  ██║█████╔╝ 
  ██║     ██║   ██║██╔═══╝ ██║██║     ██║   ██║   ██║       ╚════██║██║  ██║██╔═██╗ 
  ╚██████╗╚██████╔╝██║     ██║███████╗╚██████╔╝   ██║       ███████║██████╔╝██║  ██╗
   ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝ ╚═════╝    ╚═╝       ╚══════╝╚═════╝ ╚═╝  ╚═╝
```

## 📚 Table of Contents

| Demo | Name | Difficulty | Time | Description |
|------|------|------------|------|-------------|
| 01 | [GitHub MCP Server](#demo-1-github-mcp-server) | ⭐ Beginner | 10 min | Configure official GitHub MCP for Copilot |
| 02 | [IaC Validator MCP](#demo-2-iac-validator-mcp-server) | ⭐⭐ Intermediate | 20 min | Custom MCP server for Terraform/Bicep validation |
| 03 | [IaC Helper Skillset](#demo-3-iac-helper-skillset) | ⭐⭐ Intermediate | 25 min | Skillset with 3 IaC-focused endpoints |
| 04 | [Policy Checker Agent](#demo-4-policy-checker-agent) | ⭐⭐⭐ Advanced | 30 min | Full agent for Azure Policy compliance |
| 05 | [Cost Estimator Agent](#demo-5-cost-estimator-agent) | ⭐⭐⭐ Advanced | 30 min | Agent for Azure resource cost estimation |

---

## 🎯 Learning Objectives

By completing these demos, you will:

- ✅ Understand the difference between MCP Servers, Skillsets, and Agents
- ✅ Configure and use the official GitHub MCP Server
- ✅ Build custom MCP servers in Go for VS Code Copilot
- ✅ Create Copilot Skillsets with multiple endpoints
- ✅ Develop full Copilot Agents with Azure API integration
- ✅ Implement real-world IaC automation scenarios

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        GitHub Copilot Extensions                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│   ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐         │
│   │   MCP Servers   │    │   Skillsets     │    │    Agents       │         │
│   │                 │    │                 │    │                 │         │
│   │ • VS Code only  │    │ • 1-5 endpoints │    │ • Full control  │         │
│   │ • Local tools   │    │ • Declarative   │    │ • Custom logic  │         │
│   │ • File access   │    │ • Quick setup   │    │ • Streaming     │         │
│   └────────┬────────┘    └────────┬────────┘    └────────┬────────┘         │
│            │                      │                      │                   │
│            ▼                      ▼                      ▼                   │
│   ┌─────────────────────────────────────────────────────────────────┐       │
│   │                    Your IaC Workflows                            │       │
│   │                                                                  │       │
│   │  • Terraform validation    • Bicep linting                      │       │
│   │  • Azure Policy checks     • Cost estimation                    │       │
│   │  • Security scanning       • Best practices                     │       │
│   └─────────────────────────────────────────────────────────────────┘       │
│                                                                               │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🛠️ Prerequisites

### Required Tools

| Tool | Minimum Version | Installation |
|------|-----------------|--------------|
| Go | 1.21+ | [golang.org/dl](https://golang.org/dl/) |
| VS Code | 1.85+ | [code.visualstudio.com](https://code.visualstudio.com/) |
| GitHub Copilot | Latest | VS Code Extension |
| Azure CLI | 2.50+ | [docs.microsoft.com](https://docs.microsoft.com/cli/azure/install-azure-cli) |
| ngrok | 3.0+ | [ngrok.com](https://ngrok.com/) (for Skillsets/Agents) |

### Azure Setup

```bash
# Login to Azure
az login

# Set your subscription
az account set --subscription "YOUR_SUBSCRIPTION_ID"

# Verify
az account show
```

### Go Setup

```bash
# Verify Go installation
go version

# Should output: go version go1.21+ ...
```

---

## 📂 Folder Structure

```
Copilot-SDK/
├── README.md                          # This file
├── 01-mcp-servers/
│   ├── github-mcp/                    # Official GitHub MCP setup
│   │   ├── README.md
│   │   └── vscode-settings.json
│   └── iac-validator-mcp/             # Custom IaC validation MCP
│       ├── README.md
│       ├── main.go
│       ├── go.mod
│       ├── handlers/
│       │   ├── terraform.go
│       │   └── bicep.go
│       └── tools/
│           └── tools.go
├── 02-iac-skillset/                   # IaC Helper Skillset
│   ├── README.md
│   ├── main.go
│   ├── go.mod
│   ├── endpoints/
│   │   ├── validate.go
│   │   ├── generate.go
│   │   └── explain.go
│   └── manifest.json
├── 03-policy-agent/                   # Policy Checker Agent
│   ├── README.md
│   ├── main.go
│   ├── go.mod
│   ├── agent/
│   │   ├── handler.go
│   │   └── azure.go
│   └── policies/
│       └── rules.json
├── 04-cost-estimator/                 # Cost Estimator Agent
│   ├── README.md
│   ├── main.go
│   ├── go.mod
│   ├── agent/
│   │   ├── handler.go
│   │   └── pricing.go
│   └── data/
│       └── azure-pricing.json
└── setup-guides/
    ├── github-app-setup.md
    ├── ngrok-setup.md
    └── troubleshooting.md
```

---

## 🚀 Quick Start

### Demo 1: GitHub MCP Server (Easiest)

```bash
cd 01-mcp-servers/github-mcp
# Follow README.md to configure VS Code settings
```

### Demo 2-5: Build and Run

```bash
# Example for IaC Validator MCP
cd 01-mcp-servers/iac-validator-mcp
go mod tidy
go build -o iac-validator
./iac-validator
```

---

## 📖 Demo Details

### Demo 1: GitHub MCP Server

**What you'll learn:** Configure the official GitHub MCP Server to give Copilot access to your repos, issues, and PRs directly in VS Code.

**Key concepts:**
- MCP (Model Context Protocol) basics
- VS Code MCP configuration
- GitHub authentication

[→ Go to Demo 1](./01-mcp-servers/github-mcp/README.md)

---

### Demo 2: IaC Validator MCP Server

**What you'll learn:** Build a custom MCP server in Go that validates Terraform and Bicep files, providing real-time feedback to Copilot.

**Key concepts:**
- MCP server implementation in Go
- Tool definitions and handlers
- Integration with `terraform validate` and `az bicep build`

[→ Go to Demo 2](./01-mcp-servers/iac-validator-mcp/README.md)

---

### Demo 3: IaC Helper Skillset

**What you'll learn:** Create a Copilot Skillset with three endpoints for IaC workflows: validate, generate, and explain.

**Key concepts:**
- Skillset architecture
- Multiple endpoint handling
- GitHub App integration

[→ Go to Demo 3](./02-iac-skillset/README.md)

---

### Demo 4: Policy Checker Agent

**What you'll learn:** Develop a full Copilot Agent that checks your IaC against Azure Policy definitions and security best practices.

**Key concepts:**
- Agent event handling
- Azure Policy API integration
- Streaming responses

[→ Go to Demo 4](./03-policy-agent/README.md)

---

### Demo 5: Cost Estimator Agent

**What you'll learn:** Build an agent that estimates Azure resource costs based on your Terraform or Bicep configurations using the Azure Retail Prices API.

**Key concepts:**
- Azure Retail Prices API
- Resource parsing from IaC
- Cost calculation and formatting

[→ Go to Demo 5](./04-cost-estimator/README.md)

---

## 🔗 Resources

### Official Documentation

- [GitHub Copilot Extensions](https://docs.github.com/en/copilot/building-copilot-extensions)
- [MCP Specification](https://modelcontextprotocol.io/)
- [GitHub MCP Server](https://github.com/github/github-mcp-server)
- [Copilot Extensions SDK](https://github.com/copilot-extensions/preview-sdk.js)

### Example Repositories

- [Blackbeard Extension (Go)](https://github.com/copilot-extensions/blackbeard-extension)
- [Skillset Example](https://github.com/copilot-extensions/skillset-example)
- [RAG Extension](https://github.com/copilot-extensions/rag-extension)
- [Function Calling Extension](https://github.com/copilot-extensions/function-calling-extension)

### Azure APIs Used

- [Azure Policy REST API](https://docs.microsoft.com/rest/api/policy/)
- [Azure Retail Prices API](https://docs.microsoft.com/rest/api/cost-management/retail-prices/)
- [Azure Resource Manager API](https://docs.microsoft.com/rest/api/resources/)

---

## 🏆 Achievements

Complete the demos to unlock achievements:

| Achievement | Requirement | Badge |
|-------------|-------------|-------|
| MCP Rookie | Complete Demo 1 | 🟢 |
| Server Builder | Complete Demo 2 | 🔵 |
| Skillset Creator | Complete Demo 3 | 🟣 |
| Agent Developer | Complete Demo 4 | 🟠 |
| Full Stack AI | Complete all 5 demos | 🏅 |

---

## 💡 Tips

1. **Start with Demo 1** - It's configuration-only and helps you understand MCP
2. **Use ngrok for development** - Essential for Skillsets and Agents
3. **Check Azure quotas** - Some demos make API calls that may have rate limits
4. **Read the error messages** - Go provides excellent error context
5. **Use Copilot to help!** - Ask Copilot to explain the code as you build

---

## 🤝 Contributing

Found a bug or want to add a feature? PRs are welcome!

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

<div align="center">

**Built with ❤️ for the GitHub Copilot IaC Lab**

[← Back to Main Lab](../README.md) | [Report Issue](https://github.com/heisenberg-alt/copilot-IaC-lab/issues)

</div>
