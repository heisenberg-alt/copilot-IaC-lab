# 🐙 Demo 1: GitHub MCP Server

> **Difficulty:** ⭐ Beginner | **Time:** 10 minutes

Configure the official GitHub MCP Server to supercharge your Copilot experience with repository access, issue management, and PR workflows—all from VS Code.

```
  ┌──────────────────────────────────────────────────────────────┐
  │                                                              │
  │    ┌─────────┐         ┌─────────┐         ┌─────────┐      │
  │    │ VS Code │ ──────▶ │   MCP   │ ──────▶ │ GitHub  │      │
  │    │ Copilot │ ◀────── │ Server  │ ◀────── │   API   │      │
  │    └─────────┘         └─────────┘         └─────────┘      │
  │                                                              │
  │    "Search my repos"   Translates      Returns results      │
  │    "Create an issue"   to API calls    from GitHub          │
  │                                                              │
  └──────────────────────────────────────────────────────────────┘
```

## 📋 What You'll Learn

- What MCP (Model Context Protocol) is and why it matters
- How to configure VS Code to use MCP servers
- Available tools in the GitHub MCP Server
- Practical examples of using GitHub MCP with Copilot

---

## 🎯 Objectives

1. ✅ Understand MCP architecture
2. ✅ Configure GitHub MCP Server in VS Code
3. ✅ Authenticate with GitHub
4. ✅ Use Copilot to interact with your repositories

---

## 📚 What is MCP?

**Model Context Protocol (MCP)** is an open standard that allows AI assistants to interact with external tools and data sources. Think of it as a "plugin system" for AI.

### Why MCP?

| Without MCP | With MCP |
|-------------|----------|
| Copilot only sees your current file | Copilot can search your repos |
| Manual copy-paste of issues | Copilot creates issues for you |
| Switch between GitHub.com and VS Code | Everything in one place |

### MCP Components

```
┌─────────────────────────────────────────────────────────────┐
│                      MCP Architecture                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│   ┌──────────┐    ┌──────────┐    ┌──────────┐             │
│   │  Client  │    │  Server  │    │   Tool   │             │
│   │(VS Code) │───▶│  (MCP)   │───▶│(GitHub)  │             │
│   └──────────┘    └──────────┘    └──────────┘             │
│                                                              │
│   Sends user      Processes &     Executes                  │
│   requests        routes calls    actions                   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 🛠️ Prerequisites

- [x] VS Code 1.85 or later
- [x] GitHub Copilot extension installed
- [x] GitHub account with a Personal Access Token (PAT)
- [x] Node.js 18+ (for running the MCP server)

---

## 📝 Step 1: Create a GitHub Personal Access Token

1. Go to [GitHub Settings → Developer Settings → Personal Access Tokens → Tokens (classic)](https://github.com/settings/tokens)

2. Click **"Generate new token (classic)"**

3. Set the following scopes:

   ```
   ☑️ repo (Full control of private repositories)
   ☑️ read:org (Read org membership)
   ☑️ read:user (Read user profile data)
   ☑️ user:email (Access user email addresses)
   ☑️ read:project (Read project boards)
   ```

4. Click **"Generate token"**

5. **Copy the token** (you won't see it again!)

6. Store it securely:

   **Windows (PowerShell):**
   ```powershell
   [System.Environment]::SetEnvironmentVariable('GITHUB_PERSONAL_ACCESS_TOKEN', 'ghp_YOUR_TOKEN_HERE', 'User')
   ```

   **macOS/Linux:**
   ```bash
   echo 'export GITHUB_PERSONAL_ACCESS_TOKEN="ghp_YOUR_TOKEN_HERE"' >> ~/.bashrc
   source ~/.bashrc
   ```

---

## 📝 Step 2: Install the GitHub MCP Server

The GitHub MCP Server is distributed as an npm package:

```bash
# Install globally
npm install -g @modelcontextprotocol/server-github

# Verify installation
npx @modelcontextprotocol/server-github --help
```

---

## 📝 Step 3: Configure VS Code

### Option A: User Settings (Recommended)

1. Open VS Code Settings (`Ctrl+,` / `Cmd+,`)
2. Search for "mcp"
3. Click "Edit in settings.json"
4. Add the GitHub MCP configuration:

```json
{
  "github.copilot.chat.mcp.servers": {
    "github": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-github"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${env:GITHUB_PERSONAL_ACCESS_TOKEN}"
      }
    }
  }
}
```

### Option B: Workspace Settings

Create `.vscode/settings.json` in your project:

```json
{
  "github.copilot.chat.mcp.servers": {
    "github": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-github"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${env:GITHUB_PERSONAL_ACCESS_TOKEN}"
      }
    }
  }
}
```

---

## 📝 Step 4: Verify the Configuration

1. **Restart VS Code** (required for MCP changes)

2. Open the **Copilot Chat** panel (`Ctrl+Shift+I` / `Cmd+Shift+I`)

3. Look for the **MCP tools indicator** (🔧) in the chat

4. Type a test query:
   ```
   @github List my repositories
   ```

You should see Copilot using the GitHub MCP tools!

---

## 🔧 Available Tools

The GitHub MCP Server provides these tools to Copilot:

### Repository Tools

| Tool | Description | Example Prompt |
|------|-------------|----------------|
| `search_repositories` | Search GitHub repos | "Find repos about terraform modules" |
| `get_repository` | Get repo details | "Show me details of microsoft/vscode" |
| `list_commits` | List recent commits | "What were the last 5 commits?" |
| `get_file_contents` | Read file from repo | "Show me the README from my repo" |

### Issue Tools

| Tool | Description | Example Prompt |
|------|-------------|----------------|
| `list_issues` | List repo issues | "Show open issues in this repo" |
| `create_issue` | Create new issue | "Create an issue about the login bug" |
| `update_issue` | Update existing issue | "Close issue #42" |
| `search_issues` | Search across issues | "Find issues mentioning terraform" |

### Pull Request Tools

| Tool | Description | Example Prompt |
|------|-------------|----------------|
| `list_pull_requests` | List PRs | "Show open PRs" |
| `get_pull_request` | Get PR details | "Summarize PR #15" |
| `create_pull_request` | Create new PR | "Create a PR from feature to main" |
| `get_pull_request_diff` | Get PR diff | "Show me what changed in PR #15" |

### Branch Tools

| Tool | Description | Example Prompt |
|------|-------------|----------------|
| `list_branches` | List branches | "What branches exist?" |
| `create_branch` | Create branch | "Create a branch called feature/auth" |

---

## 🎮 Hands-On Exercises

### Exercise 1: Repository Exploration

Open Copilot Chat and try these prompts:

```
1. "List my GitHub repositories"

2. "Search for Azure Terraform modules with more than 100 stars"

3. "Show me the README from hashicorp/terraform-provider-azurerm"
```

### Exercise 2: Issue Management

```
1. "Create an issue titled 'Add input validation' with the label 'enhancement'"

2. "List all open issues with the 'bug' label"

3. "Search for issues mentioning 'authentication' in microsoft/vscode"
```

### Exercise 3: PR Workflow

```
1. "Show me all open pull requests in this repository"

2. "Get the diff for the most recent PR"

3. "List PRs that are ready for review"
```

---

## 🔧 Troubleshooting

### MCP Server Not Starting

```
Error: Cannot find module '@modelcontextprotocol/server-github'
```

**Solution:** Install the package globally:
```bash
npm install -g @modelcontextprotocol/server-github
```

### Authentication Errors

```
Error: Bad credentials
```

**Solution:** 
1. Verify your token is set: `echo $GITHUB_PERSONAL_ACCESS_TOKEN`
2. Regenerate the token if expired
3. Check token scopes include required permissions

### Tools Not Appearing

**Solution:**
1. Restart VS Code completely
2. Check the Output panel → "GitHub Copilot" for errors
3. Verify settings.json syntax is valid

---

## 📋 Complete Settings Reference

Here's a complete `settings.json` with all options:

```json
{
  "github.copilot.chat.mcp.servers": {
    "github": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-github"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${env:GITHUB_PERSONAL_ACCESS_TOKEN}"
      }
    }
  },
  
  // Optional: Enable MCP logging for debugging
  "github.copilot.chat.mcp.logLevel": "debug"
}
```

---

## ✅ Completion Checklist

- [ ] Created GitHub Personal Access Token
- [ ] Stored token in environment variable
- [ ] Installed GitHub MCP Server package
- [ ] Configured VS Code settings
- [ ] Verified MCP tools appear in Copilot Chat
- [ ] Completed at least one exercise

---

## 🎓 What's Next?

Now that you understand MCP basics, you're ready to:

1. **Demo 2:** Build your own MCP server for IaC validation
2. **Demo 3:** Create a Copilot Skillset with multiple endpoints
3. **Demo 4:** Develop a full Copilot Agent

---

## 📚 Additional Resources

- [GitHub MCP Server Repository](https://github.com/github/github-mcp-server)
- [MCP Specification](https://modelcontextprotocol.io/)
- [VS Code MCP Documentation](https://code.visualstudio.com/docs/copilot/copilot-extensibility-overview)

---

<div align="center">

**🏆 Achievement Unlocked: MCP Rookie 🟢**

[← Back to Copilot SDK](../README.md) | [Next: IaC Validator MCP →](../iac-validator-mcp/README.md)

</div>
