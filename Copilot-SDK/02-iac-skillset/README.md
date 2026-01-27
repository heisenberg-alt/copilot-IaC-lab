# 🎯 Demo 3: IaC Helper Skillset

> **Difficulty:** ⭐⭐ Intermediate | **Time:** 25 minutes

Create a Copilot Skillset with three endpoints for IaC workflows: validate, generate, and explain. Skillsets provide a simpler way to add functionality to Copilot than full agents.

```
  ┌──────────────────────────────────────────────────────────────┐
  │                    IaC Helper Skillset                        │
  ├──────────────────────────────────────────────────────────────┤
  │                                                               │
  │   GitHub.com / VS Code                                        │
  │         │                                                     │
  │         ▼                                                     │
  │   ┌─────────────────────────────────────────────────────┐    │
  │   │              Skillset (3 Endpoints)                  │    │
  │   ├─────────────────────────────────────────────────────┤    │
  │   │                                                      │    │
  │   │  /validate  ─────▶  Validate IaC files              │    │
  │   │                                                      │    │
  │   │  /generate  ─────▶  Generate IaC templates          │    │
  │   │                                                      │    │
  │   │  /explain   ─────▶  Explain IaC resources           │    │
  │   │                                                      │    │
  │   └─────────────────────────────────────────────────────┘    │
  │                                                               │
  └──────────────────────────────────────────────────────────────┘
```

## 📋 What You'll Learn

- Difference between Skillsets and Agents
- Creating a GitHub App for Copilot
- Implementing multiple skill endpoints in Go
- Exposing your skillset via ngrok

---

## 🎯 Objectives

1. ✅ Understand Skillset architecture
2. ✅ Create a GitHub App for the Skillset
3. ✅ Implement three skill endpoints
4. ✅ Deploy and test with Copilot

---

## 📚 Skillsets vs Agents

| Feature | Skillsets | Agents |
|---------|-----------|--------|
| **Endpoints** | 1-5 declarative endpoints | Unlimited, full control |
| **Complexity** | Simpler, focused | Complex, flexible |
| **Control** | Copilot calls LLM | You control LLM interaction |
| **Best for** | Specific tasks | Complex workflows |

Skillsets are ideal when you want to:
- Add specific capabilities without building a full agent
- Let Copilot handle the conversation flow
- Focus on the "what" rather than "how"

---

## 🛠️ Prerequisites

- Go 1.21+
- GitHub account
- ngrok account (free tier works)
- VS Code with Copilot

---

## 📂 Project Structure

```
02-iac-skillset/
├── go.mod
├── go.sum
├── main.go                # HTTP server & routing
├── endpoints/
│   ├── validate.go        # /validate endpoint
│   ├── generate.go        # /generate endpoint
│   └── explain.go         # /explain endpoint
├── middleware/
│   └── auth.go            # GitHub signature verification
└── manifest.json          # Skillset definition
```

---

## 📝 Step 1: Create GitHub App

1. Go to [GitHub Developer Settings](https://github.com/settings/apps/new)

2. Fill in the form:
   - **Name:** `IaC Helper Skillset`
   - **Homepage URL:** `https://github.com/your-username/copilot-iac-lab`
   - **Callback URL:** Leave empty for now
   - **Webhook:** Uncheck "Active"

3. Under **Permissions & events:**
   - **Account permissions:** None needed for skillsets
   - **Repository permissions:** Read-only for Contents (optional)

4. Under **Copilot:**
   - Check **"Copilot Extension"**
   - Extension Type: **Skillset**

5. Click **Create GitHub App**

6. Note your:
   - **App ID**
   - **Client ID**  
   - Generate a **Private Key** (download and save)

---

## 📝 Step 2: Configure ngrok

1. Install ngrok:
   ```bash
   # macOS
   brew install ngrok
   
   # Windows (winget)
   winget install ngrok
   
   # Or download from ngrok.com
   ```

2. Authenticate:
   ```bash
   ngrok config add-authtoken YOUR_AUTH_TOKEN
   ```

3. Start tunnel:
   ```bash
   ngrok http 8080
   ```

4. Note your public URL (e.g., `https://abc123.ngrok.io`)

5. Update your GitHub App:
   - Go back to your GitHub App settings
   - Set **Callback URL** to: `https://abc123.ngrok.io/callback`

---

## 📝 Step 3: Run the Skillset

```bash
cd Copilot-SDK/02-iac-skillset

# Set environment variables
export GITHUB_APP_ID="your-app-id"
export GITHUB_WEBHOOK_SECRET="your-webhook-secret"  # Optional

# Build and run
go mod tidy
go run .

# Server starts on :8080
```

---

## 🔧 Endpoint Specifications

### POST /validate

Validates Terraform or Bicep code.

**Request:**
```json
{
  "code": "resource azurerm_resource_group...",
  "type": "terraform"
}
```

**Response:**
```json
{
  "valid": false,
  "errors": [
    {
      "line": 5,
      "message": "Missing required argument: location"
    }
  ]
}
```

### POST /generate

Generates IaC templates from descriptions.

**Request:**
```json
{
  "description": "Azure storage account with blob container",
  "type": "bicep"
}
```

**Response:**
```json
{
  "code": "@description('Storage account name')\nparam storageAccountName string...",
  "language": "bicep"
}
```

### POST /explain

Explains IaC resources and their properties.

**Request:**
```json
{
  "resource": "azurerm_kubernetes_cluster",
  "property": "default_node_pool"
}
```

**Response:**
```json
{
  "explanation": "The default_node_pool block configures...",
  "examples": ["..."],
  "documentation_url": "https://..."
}
```

---

## 📋 Manifest Definition

The `manifest.json` defines your skillset for GitHub:

```json
{
  "name": "iac-helper",
  "description": "Infrastructure as Code helper for Terraform and Bicep",
  "skills": [
    {
      "name": "validate",
      "description": "Validate IaC code for syntax and best practices",
      "endpoint": "/validate"
    },
    {
      "name": "generate", 
      "description": "Generate IaC templates from descriptions",
      "endpoint": "/generate"
    },
    {
      "name": "explain",
      "description": "Explain IaC resources and configurations",
      "endpoint": "/explain"
    }
  ]
}
```

---

## 🎮 Usage Examples

### In GitHub.com Copilot Chat

```
@iac-helper validate this Terraform:
resource "azurerm_storage_account" "example" {
  name = "storageacc"
}

@iac-helper generate a Bicep template for an AKS cluster with 3 nodes

@iac-helper explain the azurerm_virtual_network resource
```

### In VS Code Copilot Chat

```
@iac-helper /validate my Terraform in the current file

@iac-helper /generate Azure Function App with consumption plan

@iac-helper /explain what does enable_rbac do in AKS?
```

---

## 🧪 Testing Locally

```bash
# Test validate endpoint
curl -X POST http://localhost:8080/validate \
  -H "Content-Type: application/json" \
  -d '{"code": "resource \"azurerm_resource_group\" \"example\" {}", "type": "terraform"}'

# Test generate endpoint
curl -X POST http://localhost:8080/generate \
  -H "Content-Type: application/json" \
  -d '{"description": "Azure storage account", "type": "bicep"}'

# Test explain endpoint
curl -X POST http://localhost:8080/explain \
  -H "Content-Type: application/json" \
  -d '{"resource": "azurerm_kubernetes_cluster"}'
```

---

## 🔒 Security Considerations

1. **Verify GitHub signatures** - Always validate incoming requests
2. **Rate limiting** - Implement to prevent abuse
3. **Input validation** - Sanitize all user input
4. **HTTPS only** - ngrok provides this automatically

---

## ✅ Completion Checklist

- [ ] Created GitHub App for Skillset
- [ ] Configured ngrok tunnel
- [ ] Implemented validate endpoint
- [ ] Implemented generate endpoint
- [ ] Implemented explain endpoint
- [ ] Tested with Copilot Chat

---

<div align="center">

**🏆 Achievement Unlocked: Skillset Creator 🟣**

[← Back to Copilot SDK](../README.md) | [Next: Policy Checker Agent →](../03-policy-agent/README.md)

</div>
