# 📱 GitHub App Setup Guide

This guide walks you through creating a GitHub App for your Copilot Extension (Skillset or Agent).

## Prerequisites

- GitHub account
- For Agents: A public HTTPS endpoint (use ngrok for development)

---

## Step 1: Create GitHub App

1. Go to **GitHub Settings** → **Developer settings** → **GitHub Apps**
   
   Direct link: https://github.com/settings/apps

2. Click **"New GitHub App"**

3. Fill in the basic information:

   | Field | Value |
   |-------|-------|
   | **App name** | `Your Extension Name` (must be unique) |
   | **Homepage URL** | Your repo or website URL |
   | **Description** | Brief description of what your extension does |

---

## Step 2: Configure Webhook (for Agents)

For **Skillsets**: Skip this section (uncheck "Active" under Webhook)

For **Agents**:

1. Check **"Active"** under Webhook
2. Set **Webhook URL** to your endpoint:
   - Development: `https://your-subdomain.ngrok.io/agent`
   - Production: `https://your-domain.com/agent`
3. Generate a **Webhook secret** and save it securely

---

## Step 3: Set Permissions

### For Skillsets

Minimal permissions needed:
- No special permissions required for basic skillsets
- Add repository permissions if accessing code

### For Agents

Recommended permissions:
- **Repository permissions**:
  - Contents: Read-only (if accessing files)
  - Metadata: Read-only
- **Account permissions**:
  - (Usually none needed)

---

## Step 4: Enable Copilot Extension

1. Scroll to **"Copilot"** section

2. Check **"Copilot Extension"**

3. Choose Extension Type:
   - **Skillset**: For declarative endpoints (1-5 skills)
   - **Agent**: For full control over responses

4. For Skillsets, fill in:
   - **Skill definitions URL**: `https://your-endpoint/manifest.json`

5. For Agents, fill in:
   - **Inference description**: Describe what your agent does
   - **Callback URL**: `https://your-endpoint/agent`

---

## Step 5: Create the App

1. Click **"Create GitHub App"**

2. Note down:
   - **App ID**: Displayed at the top
   - **Client ID**: Under "About"

3. Generate and download a **Private Key**:
   - Scroll to "Private keys"
   - Click "Generate a private key"
   - Save the `.pem` file securely

---

## Step 6: Install the App

1. Go to your app's page
2. Click **"Install App"** in the left sidebar
3. Choose where to install:
   - Your personal account
   - An organization you own/admin
4. Select repositories (if applicable)
5. Click **"Install"**

---

## Step 7: Test with Copilot

1. Open **VS Code** or **GitHub.com**

2. Open Copilot Chat

3. Type `@your-app-name` followed by a command

   Example:
   ```
   @iac-helper validate my Terraform code
   ```

---

## Troubleshooting

### Extension Not Appearing

- Verify the app is installed for your account/org
- Check that Copilot Extension is enabled in app settings
- Restart VS Code

### Webhook Errors

- Verify webhook URL is accessible
- Check webhook secret matches your server config
- Look at webhook delivery logs in app settings

### Permission Denied

- Review required permissions
- Reinstall the app to apply new permissions

---

## Environment Variables

Store these securely for your server:

```bash
# GitHub App credentials
export GITHUB_APP_ID="123456"
export GITHUB_CLIENT_ID="Iv1.abc123..."
export GITHUB_WEBHOOK_SECRET="your-webhook-secret"

# Path to private key
export GITHUB_PRIVATE_KEY_PATH="/path/to/private-key.pem"
```

---

## Security Best Practices

1. **Never commit secrets** - Use environment variables
2. **Verify webhooks** - Always validate GitHub signatures
3. **Use HTTPS** - Required for production
4. **Minimal permissions** - Only request what you need
5. **Rotate keys** - Periodically regenerate private keys

---

## Resources

- [Creating GitHub Apps](https://docs.github.com/en/apps/creating-github-apps)
- [Copilot Extensions Documentation](https://docs.github.com/en/copilot/building-copilot-extensions)
- [Webhook Payloads](https://docs.github.com/en/webhooks/webhook-events-and-payloads)
