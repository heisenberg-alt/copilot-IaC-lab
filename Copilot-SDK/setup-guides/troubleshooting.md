# 🔧 Troubleshooting Guide

Common issues and solutions when building Copilot Extensions.

---

## MCP Server Issues

### Server Not Starting

**Symptom:** MCP server fails to start or crashes immediately

**Solutions:**
1. Check Go version: `go version` (need 1.21+)
2. Run `go mod tidy` to fix dependencies
3. Check for port conflicts: `lsof -i :8080` (macOS/Linux) or `netstat -ano | findstr :8080` (Windows)
4. Enable debug logging: `DEBUG=1 go run .`

### MCP Tools Not Appearing in VS Code

**Symptom:** Copilot Chat doesn't show your MCP tools

**Solutions:**
1. Restart VS Code completely
2. Verify settings.json syntax is valid
3. Check MCP server path is absolute
4. Look for errors in Output → "GitHub Copilot"

**Example settings.json:**
```json
{
  "github.copilot.chat.mcp.servers": {
    "iac-validator": {
      "command": "C:/path/to/iac-validator.exe",
      "args": []
    }
  }
}
```

### "Cannot find module" Error

**Symptom:** Go can't find dependencies

**Solutions:**
```bash
# Clean module cache
go clean -modcache

# Re-download dependencies
go mod download

# Tidy modules
go mod tidy
```

---

## Skillset Issues

### Skillset Not Responding

**Symptom:** @your-skillset command returns nothing

**Solutions:**
1. Verify server is running and accessible
2. Test endpoint directly: `curl -X POST http://localhost:8080/validate`
3. Check ngrok is forwarding correctly
4. Verify GitHub App is installed for your account

### "Invalid Signature" Error

**Symptom:** Requests rejected with signature error

**Solutions:**
1. Verify GITHUB_WEBHOOK_SECRET matches GitHub App
2. Check secret isn't URL-encoded
3. Ensure request body isn't modified before verification

### Manifest Not Loading

**Symptom:** GitHub can't load skill definitions

**Solutions:**
1. Test manifest URL directly: `curl https://your-ngrok.io/manifest.json`
2. Verify JSON is valid
3. Check CORS headers if needed
4. Ensure HTTPS (not HTTP)

---

## Agent Issues

### SSE Stream Not Working

**Symptom:** Responses appear all at once instead of streaming

**Solutions:**
1. Ensure response headers are set correctly:
   ```go
   w.Header().Set("Content-Type", "text/event-stream")
   w.Header().Set("Cache-Control", "no-cache")
   w.Header().Set("Connection", "keep-alive")
   ```
2. Call `flusher.Flush()` after each event
3. Disable output buffering: `w.Header().Set("X-Accel-Buffering", "no")`

### Events Not Parsed by Copilot

**Symptom:** Copilot shows raw JSON instead of formatted response

**Solutions:**
1. Verify event format:
   ```
   event: copilot_message
   data: {"content": "Hello"}
   
   ```
   (note the double newline)
2. Use correct event types: `copilot_message`, `copilot_references`, `copilot_confirmation`
3. Ensure JSON is valid

### Agent Timeout

**Symptom:** Request times out before completing

**Solutions:**
1. Stream responses incrementally (don't wait for full response)
2. Add keep-alive messages for long operations
3. Increase timeout on client side if possible
4. Break large operations into smaller chunks

---

## Azure API Issues

### "Unauthorized" from Azure APIs

**Symptom:** Azure API calls return 401 or 403

**Solutions:**
1. Login to Azure CLI: `az login`
2. Check token isn't expired: `az account get-access-token`
3. Verify subscription ID: `az account show`
4. Check required permissions are assigned

### Azure Retail Prices API Errors

**Symptom:** Pricing API returns errors or no data

**Solutions:**
1. Verify filter syntax (OData format)
2. Check region name matches ARM region names
3. URL-encode filter parameters
4. Test in browser first:
   ```
   https://prices.azure.com/api/retail/prices?$filter=serviceName eq 'Virtual Machines'
   ```

### Rate Limiting

**Symptom:** API returns 429 Too Many Requests

**Solutions:**
1. Add retry with exponential backoff
2. Cache pricing data (prices don't change frequently)
3. Batch requests where possible
4. Use local fallback prices

---

## Terraform/Bicep Validation Issues

### "terraform not found"

**Symptom:** Terraform CLI not available

**Solutions:**
1. Install Terraform: https://www.terraform.io/downloads
2. Add to PATH
3. Verify: `terraform version`
4. For Windows, try full path: `C:\terraform\terraform.exe`

### "az bicep" Errors

**Symptom:** Bicep validation fails

**Solutions:**
1. Install Azure CLI: `az --version`
2. Install Bicep: `az bicep install`
3. Update Bicep: `az bicep upgrade`
4. Verify: `az bicep version`

### Validation Takes Too Long

**Symptom:** terraform validate hangs

**Solutions:**
1. Use `terraform init -backend=false` to skip backend config
2. Set timeout on exec commands
3. Run validation in temp directory
4. Skip provider downloads with `-plugin-dir`

---

## ngrok Issues

### "Tunnel session ended"

**Symptom:** ngrok tunnel stops unexpectedly

**Solutions:**
1. Check ngrok account limits (free tier has limits)
2. Verify authtoken: `ngrok config check`
3. Try different region: `ngrok http 8080 --region=eu`
4. Check firewall/proxy settings

### URL Changes Every Restart

**Symptom:** Have to update GitHub App every restart

**Solutions:**
1. Use paid ngrok plan for static subdomain
2. Script GitHub App update via API
3. Use alternative like Cloudflare Tunnel
4. Deploy to staging server for testing

---

## GitHub App Issues

### App Not Visible in Copilot

**Symptom:** Can't invoke your extension with @mention

**Solutions:**
1. Verify app is installed for your account
2. Check "Copilot Extension" is enabled in app settings
3. Ensure extension type (Skillset/Agent) is correct
4. Restart VS Code / refresh GitHub.com

### Webhook Delivery Failures

**Symptom:** Webhooks showing as failed in GitHub

**Solutions:**
1. Check webhook URL is accessible (test with curl)
2. Verify server is running
3. Check webhook secret matches
4. Look at request/response in webhook delivery log

---

## Debugging Tips

### Enable Verbose Logging

```go
// Add to your server
func debugLog(format string, args ...interface{}) {
    if os.Getenv("DEBUG") != "" {
        log.Printf("[DEBUG] "+format, args...)
    }
}
```

Run with: `DEBUG=1 go run .`

### Test Endpoints Directly

```bash
# Test MCP server
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | ./your-server

# Test HTTP endpoints
curl -X POST http://localhost:8080/validate \
  -H "Content-Type: application/json" \
  -d '{"code": "test", "type": "terraform"}'

# Test SSE endpoint
curl -N http://localhost:8080/agent \
  -H "Content-Type: application/json" \
  -H "Accept: text/event-stream" \
  -d '{"messages": [{"role": "user", "content": "test"}]}'
```

### Inspect Network Traffic

- Use ngrok's web interface: http://127.0.0.1:4040
- Browser DevTools → Network tab
- Wireshark for detailed analysis

---

## Getting Help

1. **GitHub Copilot Docs**: https://docs.github.com/copilot
2. **MCP Specification**: https://modelcontextprotocol.io
3. **GitHub Community**: https://github.community
4. **Stack Overflow**: Tag `github-copilot`
