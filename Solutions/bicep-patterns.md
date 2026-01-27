# Bicep Patterns Quick Reference

## Parameters with Decorators
```bicep
@description('The deployment environment')
@allowed(['dev', 'staging', 'prod'])
param environment string = 'dev'

@description('Azure region for deployment')
param location string = resourceGroup().location

@description('Administrator password')
@secure()
@minLength(12)
param adminPassword string

@description('Number of instances')
@minValue(1)
@maxValue(10)
param instanceCount int = 2
```

## Variables for Naming
```bicep
var namePrefix = '${project}-${environment}-${location}'
var resourceGroupName = 'rg-${namePrefix}'

var commonTags = {
  environment: environment
  project: project
  managedBy: 'bicep'
}
```

## Resource with Tags
```bicep
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: 'st${uniqueString(resourceGroup().id)}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
  }
  tags: commonTags
}
```

## Loops with Index
```bicep
param subnetConfigs array = [
  { name: 'web', prefix: '10.0.1.0/24' }
  { name: 'app', prefix: '10.0.2.0/24' }
  { name: 'data', prefix: '10.0.3.0/24' }
]

resource vnet 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: 'vnet-${namePrefix}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
    subnets: [for (config, i) in subnetConfigs: {
      name: 'snet-${config.name}'
      properties: {
        addressPrefix: config.prefix
      }
    }]
  }
}
```

## Conditional Deployment
```bicep
param deployMonitoring bool = true

resource appInsights 'Microsoft.Insights/components@2020-02-02' = if (deployMonitoring) {
  name: 'appi-${namePrefix}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
  tags: commonTags
}

output appInsightsKey string = deployMonitoring ? appInsights.properties.InstrumentationKey : ''
```

## Modules
```bicep
// main.bicep
module storage 'modules/storage.bicep' = {
  name: 'storageDeployment'
  params: {
    namePrefix: namePrefix
    location: location
    tags: commonTags
  }
}

output storageAccountId string = storage.outputs.storageAccountId

// modules/storage.bicep
@description('Name prefix for resources')
param namePrefix string

@description('Azure region')
param location string

@description('Resource tags')
param tags object

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: 'st${uniqueString(namePrefix)}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  tags: tags
}

@description('Storage account resource ID')
output storageAccountId string = storageAccount.id
```

## Resource Dependencies
```bicep
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: 'kv-${namePrefix}'
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
  }
}

resource secret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'connectionString'
  properties: {
    value: storageAccount.properties.primaryEndpoints.blob
  }
}
```

## Existing Resources
```bicep
resource existingVnet 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: 'vnet-shared'
  scope: resourceGroup('rg-networking')
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' existing = {
  parent: existingVnet
  name: 'snet-apps'
}

output subnetId string = subnet.id
```

## Deployment Scopes
```bicep
// Subscription-level deployment
targetScope = 'subscription'

param resourceGroupName string
param location string

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: location
}

module resources 'resources.bicep' = {
  scope: rg
  name: 'resourcesDeployment'
  params: {
    location: location
  }
}
```
