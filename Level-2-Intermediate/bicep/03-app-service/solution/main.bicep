// =============================================================================
// Level 2.3: App Service - Solution
// =============================================================================

@description('Environment')
param environment string = 'dev'

@description('Location')
param location string = 'eastus'

@description('Workload name')
param workload string = 'webapp'

// -----------------------------------------------------------------------------
// Variables
// -----------------------------------------------------------------------------
var namePrefix = '${workload}-${environment}'
var uniqueSuffix = uniqueString(resourceGroup().id)
var commonTags = {
  environment: environment
  project: workload
  managed_by: 'bicep'
}

// -----------------------------------------------------------------------------
// Log Analytics & Application Insights
// -----------------------------------------------------------------------------
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: 'log-${namePrefix}'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
  tags: commonTags
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'appi-${namePrefix}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
  }
  tags: commonTags
}

// -----------------------------------------------------------------------------
// App Service Plan
// -----------------------------------------------------------------------------
resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: 'asp-${namePrefix}'
  location: location
  kind: 'linux'
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
  properties: {
    reserved: true // Required for Linux
  }
  tags: commonTags
}

// -----------------------------------------------------------------------------
// Web App
// -----------------------------------------------------------------------------
resource webApp 'Microsoft.Web/sites@2023-12-01' = {
  name: 'app-${namePrefix}-${uniqueSuffix}'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'PYTHON|3.11'
      alwaysOn: false
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'ENVIRONMENT'
          value: environment
        }
      ]
    }
  }
  tags: commonTags
}

// -----------------------------------------------------------------------------
// Staging Slot
// -----------------------------------------------------------------------------
resource stagingSlot 'Microsoft.Web/sites/slots@2023-12-01' = {
  parent: webApp
  name: 'staging'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'PYTHON|3.11'
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'ENVIRONMENT'
          value: 'staging'
        }
      ]
    }
  }
  tags: commonTags
}

// -----------------------------------------------------------------------------
// Outputs
// -----------------------------------------------------------------------------
@description('Web app name')
output webAppName string = webApp.name

@description('Web app URL')
output webAppUrl string = 'https://${webApp.properties.defaultHostName}'

@description('Staging slot URL')
output stagingUrl string = 'https://${stagingSlot.properties.defaultHostName}'

@description('App Insights instrumentation key')
output appInsightsKey string = appInsights.properties.InstrumentationKey
