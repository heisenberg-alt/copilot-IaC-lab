# 🟡 Level 2.3: App Service - Web Applications

## 🎯 Objectives

By the end of this exercise, you will:
- Create Azure App Service Plans
- Deploy Web Apps
- Configure deployment slots
- Set up Application Insights

## 📚 Concepts Covered

| Concept | Description |
|---------|-------------|
| **App Service Plan** | Compute resources for web apps |
| **Web App** | Managed web application hosting |
| **Deployment Slots** | Staging environments for apps |
| **App Insights** | Application performance monitoring |
| **App Settings** | Configuration key-value pairs |

## 🤖 Copilot Prompts to Try

### Generate App Service
```
Create a Terraform configuration for Azure App Service with:
- Linux App Service Plan (B1 SKU)
- Python 3.11 web app
- Staging deployment slot
- Application Insights integration
- App settings from a map variable
```

### Generate Monitoring
```
Create Application Insights resource connected to a web app
Configure diagnostic settings to send logs to Log Analytics
```

## 📋 Challenge

Create a complete web app deployment:

### Requirements

| Resource | Configuration |
|----------|--------------|
| App Service Plan | Linux, B1 SKU |
| Web App | Python 3.11 runtime |
| Slot | Staging slot |
| App Insights | Connected monitoring |
| App Settings | From variable map |

## 💡 Hints

<details>
<summary>Hint 1: App Service Plan</summary>

```hcl
resource "azurerm_service_plan" "main" {
  name                = "asp-${var.workload}-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "B1"
}
```
</details>

<details>
<summary>Hint 2: Web App with Settings</summary>

```hcl
resource "azurerm_linux_web_app" "main" {
  # ...
  app_settings = merge(var.app_settings, {
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.main.instrumentation_key
  })
}
```
</details>

## 📁 Files

```
03-app-service/
├── README.md
├── challenge/
│   ├── main.tf
│   └── variables.tf
└── solution/
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```
