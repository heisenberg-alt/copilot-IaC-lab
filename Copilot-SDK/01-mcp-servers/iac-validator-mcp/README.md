# 🔍 Demo 2: IaC Validator MCP Server

> **Difficulty:** ⭐⭐ Intermediate | **Time:** 20 minutes

Build a custom MCP server in Go that validates Terraform and Bicep files, providing real-time feedback directly in Copilot Chat.

```
  ┌──────────────────────────────────────────────────────────────┐
  │                  IaC Validator MCP Server                     │
  ├──────────────────────────────────────────────────────────────┤
  │                                                               │
  │   ┌─────────┐      ┌─────────────┐      ┌─────────────┐      │
  │   │ Copilot │─────▶│ MCP Server  │─────▶│ terraform   │      │
  │   │  Chat   │      │   (Go)      │      │ validate    │      │
  │   └─────────┘      └─────────────┘      └─────────────┘      │
  │        │                  │                    │              │
  │        │                  │              ┌─────────────┐      │
  │        │                  └─────────────▶│ az bicep    │      │
  │        │                                 │ build       │      │
  │        │                                 └─────────────┘      │
  │        ▼                                                      │
  │   "Your Terraform has 2 errors:                              │
  │    - Line 15: Invalid resource type                          │
  │    - Line 23: Missing required argument"                     │
  │                                                               │
  └──────────────────────────────────────────────────────────────┘
```

## 📋 What You'll Learn

- How to create an MCP server from scratch in Go
- Implementing MCP tools with JSON-RPC
- Integrating with CLI tools (terraform, az bicep)
- Error handling and response formatting

---

## 🎯 Objectives

1. ✅ Create Go project structure
2. ✅ Implement MCP protocol handlers
3. ✅ Add Terraform validation tool
4. ✅ Add Bicep validation tool
5. ✅ Configure and test in VS Code

---

## 🛠️ Prerequisites

- Go 1.21 or later
- Terraform CLI installed
- Azure CLI with Bicep extension
- VS Code with Copilot

---

## 📂 Project Structure

```
iac-validator-mcp/
├── go.mod                 # Go module definition
├── go.sum                 # Dependencies checksum
├── main.go                # Entry point & server setup
├── mcp/
│   ├── protocol.go        # MCP protocol types
│   ├── server.go          # JSON-RPC server
│   └── transport.go       # stdio transport
├── handlers/
│   ├── terraform.go       # Terraform validation
│   └── bicep.go           # Bicep validation
└── tools/
    └── registry.go        # Tool definitions
```

---

## 📝 Implementation

### Step 1: Initialize Go Module

```bash
cd Copilot-SDK/01-mcp-servers/iac-validator-mcp
go mod init github.com/your-org/iac-validator-mcp
```

### Step 2: Build and Run

```bash
# Build the server
go build -o iac-validator .

# Test locally
echo '{"jsonrpc":"2.0","id":1,"method":"initialize"}' | ./iac-validator
```

### Step 3: Configure VS Code

Add to your VS Code settings:

```json
{
  "github.copilot.chat.mcp.servers": {
    "iac-validator": {
      "command": "path/to/iac-validator",
      "args": []
    }
  }
}
```

---

## 🔧 Available Tools

| Tool | Description | Parameters |
|------|-------------|------------|
| `validate_terraform` | Validate Terraform files | `path`: Directory or file path |
| `validate_bicep` | Validate Bicep files | `path`: Bicep file path |
| `check_iac_syntax` | Quick syntax check | `code`: IaC code string, `type`: terraform\|bicep |

---

## 🎮 Usage Examples

### In Copilot Chat

```
"Validate my Terraform files in the current directory"

"Check if this Bicep file has any errors: main.bicep"

"Run syntax check on this code:
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'mystorageaccount'
}"
```

---

## 🧪 Testing

```bash
# Run tests
go test ./...

# Run with debug output
DEBUG=1 ./iac-validator
```

---

## ✅ Completion Checklist

- [ ] Created Go project structure
- [ ] Implemented MCP protocol handlers
- [ ] Added terraform validation tool
- [ ] Added bicep validation tool
- [ ] Configured VS Code settings
- [ ] Tested with Copilot Chat

---

<div align="center">

**🏆 Achievement Unlocked: Server Builder 🔵**

[← Back to Copilot SDK](../../README.md) | [Next: IaC Skillset →](../../02-iac-skillset/README.md)

</div>
