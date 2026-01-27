# GitHub Copilot SDK Reference Guide

> **Last Updated:** January 2026  
> **SDK Version:** v5.0.1 (Latest Stable)  
> **MCP Go SDK:** v0.44.0-beta.2 (Latest)

## 📦 Official SDKs and Packages

### JavaScript/TypeScript SDK

```bash
npm install @copilot-extensions/preview-sdk
```

**Package:** [@copilot-extensions/preview-sdk](https://www.npmjs.com/package/@copilot-extensions/preview-sdk)  
**Repository:** [copilot-extensions/preview-sdk.js](https://github.com/copilot-extensions/preview-sdk.js)  
**License:** MIT

### Go MCP SDK

```bash
go get github.com/mark3labs/mcp-go
```

**Repository:** [mark3labs/mcp-go](https://github.com/mark3labs/mcp-go)  
**Stars:** 8k+ | **Used by:** 2.7k+ projects  
**License:** MIT

---

## 🎯 Key Features

### Copilot Extensions SDK (JavaScript/TypeScript)

| Feature | Description |
|---------|-------------|
| **Request Verification** | Cryptographic signature validation for secure requests |
| **Response Building** | Server-Sent Events (SSE) helpers for streaming responses |
| **Payload Parsing** | Type-safe request body parsing |
| **Prompt API** | Direct LLM prompting capabilities |
| **Function Calling** | Tool/function execution support |

### MCP Go SDK

| Feature | Description |
|---------|-------------|
| **Tools** | Execute functions and produce side effects |
| **Resources** | Expose data to LLM context |
| **Prompts** | Reusable interaction templates |
| **Session Management** | Per-client state and notifications |
| **Multiple Transports** | Stdio, SSE, and Streamable HTTP |

---

## 🔧 How to Use for This Lab's Demos

### Demo 1: GitHub MCP Server (Configuration Only)

No SDK coding required. Uses the official GitHub MCP Server.

**Setup:**
```json
// .vscode/settings.json
{
  "mcp": {
    "servers": {
      "github": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-github"],
        "env": {
          "GITHUB_PERSONAL_ACCESS_TOKEN": "${env:GITHUB_TOKEN}"
        }
      }
    }
  }
}
```

**Usage in Copilot Chat:**
```
@mcp List all issues in microsoft/terraform-provider-azurerm
@mcp Search for "Azure storage" in my repositories
@mcp Get PR #1234 details from org/repo
```

---

### Demo 2: IaC Validator MCP Server (Go)

Uses the **mcp-go** SDK to build a custom MCP server.

**Key SDK Imports:**
```go
import (
    "github.com/mark3labs/mcp-go/mcp"
    "github.com/mark3labs/mcp-go/server"
)
```

**Creating Tools:**
```go
// Define a tool with parameters
tool := mcp.NewTool("validate_terraform",
    mcp.WithDescription("Validate Terraform configuration"),
    mcp.WithString("content",
        mcp.Required(),
        mcp.Description("Terraform HCL content to validate"),
    ),
    mcp.WithString("filename",
        mcp.Description("Optional filename for context"),
    ),
)

// Register the handler
s.AddTool(tool, validateTerraformHandler)
```

**Handler Pattern:**
```go
func validateTerraformHandler(ctx context.Context, request mcp.CallToolRequest) (*mcp.CallToolResult, error) {
    // Get required parameter
    content, err := request.RequireString("content")
    if err != nil {
        return mcp.NewToolResultError(err.Error()), nil
    }
    
    // Get optional parameter
    filename := request.GetString("filename", "main.tf")
    
    // Process and return result
    return mcp.NewToolResultText("Validation passed!"), nil
}
```

**Starting the Server:**
```go
// Stdio transport (for VS Code)
if err := server.ServeStdio(s); err != nil {
    log.Fatal(err)
}
```

---

### Demo 3: IaC Helper Skillset (Go/HTTP)

Skillsets expose HTTP endpoints that GitHub Copilot can call.

**Architecture:**
```
┌─────────────────────┐     ┌─────────────────────┐
│   GitHub Copilot    │────▶│  Your Skillset API  │
│   (github.com)      │◀────│  (HTTP Endpoints)   │
└─────────────────────┘     └─────────────────────┘
```

**Endpoint Pattern:**
```go
// Each skillset can have up to 5 endpoints
http.HandleFunc("/api/generate", generateHandler)
http.HandleFunc("/api/review", reviewHandler)
http.HandleFunc("/api/explain", explainHandler)
```

**Request Structure (from Copilot):**
```json
{
  "messages": [
    {"role": "user", "content": "Generate a storage account"}
  ],
  "copilot_references": {...},
  "copilot_thread_id": "abc123"
}
```

**Response Format (SSE):**
```go
func writeSSEResponse(w http.ResponseWriter, message string) {
    w.Header().Set("Content-Type", "text/event-stream")
    
    // Acknowledge
    fmt.Fprintf(w, "event: copilot_ack\ndata: {}\n\n")
    w.(http.Flusher).Flush()
    
    // Send content
    data, _ := json.Marshal(map[string]any{
        "type": "content",
        "body": message,
    })
    fmt.Fprintf(w, "event: copilot_message\ndata: %s\n\n", data)
    w.(http.Flusher).Flush()
    
    // Complete
    fmt.Fprintf(w, "event: copilot_done\ndata: {}\n\n")
    w.(http.Flusher).Flush()
}
```

---

### Demo 4 & 5: Policy Agent & Cost Estimator (Go/HTTP)

Full agents have complete control over the conversation flow.

**Key Differences from Skillsets:**

| Feature | Skillset | Agent |
|---------|----------|-------|
| Endpoints | Up to 5 | Unlimited |
| Control | Endpoint-level | Full conversation |
| Complexity | Simpler | More powerful |
| Use Case | Specific tasks | Complex workflows |

**Agent Request Handling:**
```go
func agentHandler(w http.ResponseWriter, r *http.Request) {
    // Parse the Copilot request
    var req struct {
        Messages []Message `json:"messages"`
    }
    json.NewDecoder(r.Body).Decode(&req)
    
    // Get user's latest message
    userMessage := req.Messages[len(req.Messages)-1].Content
    
    // Process with Azure APIs
    result := processWithAzure(userMessage)
    
    // Stream response back
    streamResponse(w, result)
}
```

**Real Azure API Calls:**
```go
// Azure Resource Graph (Demo 4)
func queryAzureResources(subscriptionID, query string) ([]Resource, error) {
    url := "https://management.azure.com/providers/Microsoft.ResourceGraph/resources"
    // ... query Azure Resource Graph API
}

// Azure Retail Prices (Demo 5)
func getAzurePricing(serviceName, region string) (*PricingInfo, error) {
    url := "https://prices.azure.com/api/retail/prices"
    // ... query Azure Retail Prices API
}
```

---

## 📚 API Reference

### Copilot Extensions SDK Functions

#### Verification

```javascript
import { verifyRequestByKeyId } from "@copilot-extensions/preview-sdk";

const { isValid, cache } = await verifyRequestByKeyId(
  request.body,
  signature,
  keyId,
  { token: process.env.GITHUB_TOKEN }
);
```

#### Response Building

```javascript
import { 
  createAckEvent, 
  createTextEvent, 
  createDoneEvent,
  createConfirmationEvent,
  createReferencesEvent,
  createErrorsEvent
} from "@copilot-extensions/preview-sdk";

// Acknowledge request
response.write(createAckEvent());

// Send text (supports markdown)
response.write(createTextEvent("# Hello!\n\nHere's your **response**"));

// Ask for confirmation
response.write(createConfirmationEvent({
  id: "123",
  title: "Confirm Action",
  message: "This will create 3 Azure resources. Continue?"
}));

// Add references
response.write(createReferencesEvent([{
  id: "doc1",
  type: "documentation",
  metadata: {
    display_name: "Azure Docs",
    display_url: "https://docs.microsoft.com/azure"
  }
}]));

// Complete
response.write(createDoneEvent());
```

#### Parsing

```javascript
import { 
  parseRequestBody,
  getUserMessage,
  getUserConfirmation,
  verifyAndParseRequest
} from "@copilot-extensions/preview-sdk";

// All-in-one verify and parse
const { isValidRequest, payload, cache } = await verifyAndParseRequest(
  request.body,
  signature,
  keyId,
  { token: process.env.GITHUB_TOKEN }
);

// Get user's message
const userMessage = getUserMessage(payload);

// Check if user confirmed
const confirmation = getUserConfirmation(payload);
```

#### Prompt API

```javascript
import { prompt } from "@copilot-extensions/preview-sdk";

// Simple prompt
const { message } = await prompt("What is the capital of France?", {
  model: "gpt-4o",
  token: process.env.GITHUB_TOKEN
});

// With conversation history
const { message } = await prompt("What about Spain?", {
  model: "gpt-4o",
  token: process.env.GITHUB_TOKEN,
  messages: [
    { role: "user", content: "What is the capital of France?" },
    { role: "assistant", content: "Paris" }
  ]
});

// Streaming
const { stream } = await prompt.stream("Explain Terraform modules", {
  token: process.env.GITHUB_TOKEN
});

for await (const chunk of stream) {
  console.log(new TextDecoder().decode(chunk));
}
```

### MCP Go SDK Functions

#### Server Creation

```go
s := server.NewMCPServer(
    "My Server",          // Name
    "1.0.0",              // Version
    server.WithToolCapabilities(false),
    server.WithRecovery(),
    server.WithHooks(hooks),
)
```

#### Tool Definition

```go
tool := mcp.NewTool("tool_name",
    mcp.WithDescription("What this tool does"),
    
    // String parameter
    mcp.WithString("param1",
        mcp.Required(),
        mcp.Description("Description"),
        mcp.Enum("option1", "option2"),
    ),
    
    // Number parameter
    mcp.WithNumber("param2",
        mcp.Description("A number"),
    ),
    
    // Boolean parameter
    mcp.WithBoolean("param3",
        mcp.Description("A flag"),
    ),
)
```

#### Parameter Access

```go
func handler(ctx context.Context, req mcp.CallToolRequest) (*mcp.CallToolResult, error) {
    // Required parameters (returns error if missing)
    str, err := req.RequireString("name")
    num, err := req.RequireFloat("count")
    flag, err := req.RequireBool("enabled")
    
    // Optional parameters (with defaults)
    str := req.GetString("name", "default")
    num := req.GetFloat("count", 0.0)
    flag := req.GetBool("enabled", false)
    
    return mcp.NewToolResultText("Success"), nil
}
```

#### Response Types

```go
// Text result
return mcp.NewToolResultText("Plain text response"), nil

// JSON result
return mcp.NewToolResultJSON(myStruct), nil

// Error result
return mcp.NewToolResultError("Something went wrong"), nil

// Multiple content items
return &mcp.CallToolResult{
    Content: []mcp.Content{
        mcp.TextContent{Type: "text", Text: "Part 1"},
        mcp.TextContent{Type: "text", Text: "Part 2"},
    },
}, nil
```

---

## 🚀 Quick Start Templates

### MCP Server Template (Go)

```go
package main

import (
    "context"
    "fmt"
    "log"

    "github.com/mark3labs/mcp-go/mcp"
    "github.com/mark3labs/mcp-go/server"
)

func main() {
    s := server.NewMCPServer(
        "My IaC Tool",
        "1.0.0",
        server.WithToolCapabilities(false),
    )

    // Define tool
    tool := mcp.NewTool("my_tool",
        mcp.WithDescription("Does something useful"),
        mcp.WithString("input", mcp.Required()),
    )

    // Add handler
    s.AddTool(tool, func(ctx context.Context, req mcp.CallToolRequest) (*mcp.CallToolResult, error) {
        input, _ := req.RequireString("input")
        return mcp.NewToolResultText(fmt.Sprintf("Processed: %s", input)), nil
    })

    // Run
    if err := server.ServeStdio(s); err != nil {
        log.Fatal(err)
    }
}
```

### Copilot Extension Agent Template (Go)

```go
package main

import (
    "encoding/json"
    "fmt"
    "log"
    "net/http"
)

func main() {
    http.HandleFunc("/", handleCopilotRequest)
    log.Println("Agent running on :8080")
    log.Fatal(http.ListenAndServe(":8080", nil))
}

func handleCopilotRequest(w http.ResponseWriter, r *http.Request) {
    // Set SSE headers
    w.Header().Set("Content-Type", "text/event-stream")
    w.Header().Set("Cache-Control", "no-cache")
    
    // Parse request
    var req struct {
        Messages []struct {
            Role    string `json:"role"`
            Content string `json:"content"`
        } `json:"messages"`
    }
    json.NewDecoder(r.Body).Decode(&req)
    
    // Acknowledge
    fmt.Fprintf(w, "event: copilot_ack\ndata: {}\n\n")
    w.(http.Flusher).Flush()
    
    // Process and respond
    response := processRequest(req.Messages)
    data, _ := json.Marshal(map[string]any{
        "type": "content",
        "body": response,
    })
    fmt.Fprintf(w, "event: copilot_message\ndata: %s\n\n", data)
    w.(http.Flusher).Flush()
    
    // Done
    fmt.Fprintf(w, "event: copilot_done\ndata: {}\n\n")
}

func processRequest(messages []struct{ Role, Content string }) string {
    // Your logic here
    return "Hello from the agent!"
}
```

---

## 🔗 Official Resources

### Documentation

- [Copilot Extensions - Using Extensions](https://docs.github.com/en/copilot/using-github-copilot/using-extensions-to-integrate-external-tools-with-copilot-chat)
- [Building Copilot Extensions](https://docs.github.com/en/copilot/building-copilot-extensions/about-building-copilot-extensions)
- [Setting Up Copilot Extensions](https://docs.github.com/en/copilot/building-copilot-extensions/setting-up-copilot-extensions)
- [Copilot Platform Communication](https://docs.github.com/en/copilot/building-copilot-extensions/building-a-copilot-agent-for-your-copilot-extension/configuring-your-copilot-agent-to-communicate-with-the-copilot-platform)
- [Model Context Protocol](https://modelcontextprotocol.io/introduction)
- [MCP Go SDK Documentation](https://mcp-go.dev/)

### Example Repositories

| Repository | Description |
|------------|-------------|
| [blackbeard-extension](https://github.com/copilot-extensions/blackbeard-extension) | Simple agent example |
| [skillset-example](https://github.com/copilot-extensions/skillset-example) | Skillset implementation |
| [rag-extension](https://github.com/copilot-extensions/rag-extension) | RAG-based extension |
| [function-calling-extension](https://github.com/copilot-extensions/function-calling-extension) | Function calling demo |
| [mcp-go/examples](https://github.com/mark3labs/mcp-go/tree/main/examples) | MCP Go examples |

### Video Tutorials

- [MCP Go Tutorial](https://www.youtube.com/watch?v=qoaeYMrXJH0)

---

## 📋 Version History

### @copilot-extensions/preview-sdk

| Version | Date | Changes |
|---------|------|---------|
| v5.0.1 | Oct 5, 2024 | Readme fix for `prompt.stream` example |
| v5.0.0 | Sep 18, 2024 | **Breaking:** Verification caching support |
| v4.0.3 | Sep 10, 2024 | Required `index: 0` in choices |
| v4.0.0 | Sep 5, 2024 | **Breaking:** `create*Event` returns string |
| v3.0.0 | Sep 5, 2024 | `prompt.stream()`, custom endpoints |

### mcp-go

| Version | Date | Changes |
|---------|------|---------|
| v0.44.0-beta.2 | Jan 2026 | Auto-completion support, test client info |
| v0.43.x | Dec 2025 | Session-specific resources |
| v0.42.x | Nov 2025 | Streamable HTTP transport |

---

## 💡 Tips for This Lab

1. **Start with Demo 1** - It requires no coding, just configuration
2. **Use ngrok for local testing** - Required for GitHub.com Copilot Extensions
3. **MCP for VS Code, Extensions for GitHub.com** - Choose based on target
4. **Check Azure CLI login** - Real API calls require `az login`
5. **Test incrementally** - Verify each tool works before adding more
6. **Read the logs** - Both MCP and HTTP servers provide detailed logging

---

## 🆘 Troubleshooting

### MCP Server Won't Start

```bash
# Check Go installation
go version

# Verify dependencies
go mod tidy

# Test build
go build -o test-server .
```

### VS Code Not Detecting MCP Server

1. Check `.vscode/mcp.json` syntax
2. Reload VS Code window
3. View MCP logs in Output panel

### GitHub Extension Not Working

1. Verify ngrok is running
2. Check GitHub App callback URL
3. Ensure extension is installed for your org/user
4. Check signature verification

### Azure API Errors

```bash
# Verify Azure login
az account show

# Check subscription
az account list --output table

# Test API access
az resource list --resource-type Microsoft.Storage/storageAccounts
```

---

*This document is part of the GitHub Copilot IaC Lab - Copilot SDK Demos*
