# 🔗 ngrok Setup Guide

ngrok creates secure tunnels to expose your local development server to the internet. This is essential for testing Copilot Skillsets and Agents during development.

---

## Quick Start

### 1. Install ngrok

**macOS (Homebrew):**
```bash
brew install ngrok
```

**Windows (winget):**
```powershell
winget install ngrok
```

**Windows (Chocolatey):**
```powershell
choco install ngrok
```

**Linux (snap):**
```bash
sudo snap install ngrok
```

**Manual Download:**
Visit https://ngrok.com/download

---

### 2. Create Free Account

1. Go to https://ngrok.com
2. Sign up for a free account
3. Get your authtoken from the dashboard

---

### 3. Authenticate

```bash
ngrok config add-authtoken YOUR_AUTH_TOKEN
```

---

### 4. Start Tunnel

```bash
# Basic tunnel to port 8080
ngrok http 8080

# With custom subdomain (paid feature)
ngrok http --subdomain=my-iac-helper 8080

# With hostname inspection disabled (faster)
ngrok http 8080 --inspect=false
```

---

## Example Output

```
ngrok                                                           

Session Status                online
Account                       your-email@example.com (Plan: Free)
Version                       3.4.0
Region                        United States (us)
Latency                       45ms
Web Interface                 http://127.0.0.1:4040
Forwarding                    https://abc123.ngrok.io -> http://localhost:8080

Connections                   ttl     opn     rt1     rt5     p50     p90
                              0       0       0.00    0.00    0.00    0.00
```

Copy the **Forwarding** URL (e.g., `https://abc123.ngrok.io`)

---

## Using with Copilot Extensions

### For Skillsets

1. Start your skillset server:
   ```bash
   go run .
   # Server running on :8080
   ```

2. Start ngrok:
   ```bash
   ngrok http 8080
   ```

3. Update your GitHub App:
   - Set **Skill definitions URL** to: `https://abc123.ngrok.io/manifest.json`

### For Agents

1. Start your agent server:
   ```bash
   go run .
   # Server running on :8080
   ```

2. Start ngrok:
   ```bash
   ngrok http 8080
   ```

3. Update your GitHub App:
   - Set **Callback URL** to: `https://abc123.ngrok.io/agent`
   - Set **Webhook URL** to: `https://abc123.ngrok.io/webhook` (if using webhooks)

---

## Inspecting Traffic

ngrok provides a web interface to inspect all traffic:

1. Open http://127.0.0.1:4040 in your browser
2. See all requests/responses
3. Replay requests for debugging

---

## Tips for Development

### Keep URL Stable

Free ngrok URLs change every restart. Options:

1. **Paid plan**: Get a static subdomain
2. **ngrok config**: Save your settings
3. **Script**: Update GitHub App automatically

### Config File

Create `~/.ngrok2/ngrok.yml`:

```yaml
version: "2"
authtoken: YOUR_AUTH_TOKEN
tunnels:
  iac-helper:
    proto: http
    addr: 8080
```

Start with:
```bash
ngrok start iac-helper
```

---

## Alternatives to ngrok

If ngrok doesn't work for you:

| Tool | Free Tier | Static URLs |
|------|-----------|-------------|
| [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/) | Yes | Yes |
| [localtunnel](https://localtunnel.github.io/www/) | Yes | Custom subdomain |
| [Tailscale Funnel](https://tailscale.com/kb/1223/funnel/) | Yes | Yes (with Tailscale) |
| [bore](https://github.com/ekzhang/bore) | Yes (self-host) | Yes |

---

## Troubleshooting

### "ERR_NGROK_108" - Account Limit

Free accounts have connection limits. Solutions:
- Wait and retry
- Upgrade to paid plan
- Use an alternative

### Tunnel Not Connecting

1. Check firewall settings
2. Try a different region: `ngrok http 8080 --region=eu`
3. Verify authtoken is correct

### HTTPS Certificate Errors

ngrok provides valid HTTPS by default. If you see errors:
- Ensure your app accepts proxied requests
- Check for hardcoded HTTP URLs

### Webhook Not Receiving Events

1. Verify webhook URL in GitHub App settings
2. Check webhook delivery logs in GitHub
3. Inspect traffic at http://127.0.0.1:4040

---

## Resources

- [ngrok Documentation](https://ngrok.com/docs)
- [ngrok Free vs Paid](https://ngrok.com/pricing)
- [GitHub Webhooks Guide](https://docs.github.com/en/webhooks)
