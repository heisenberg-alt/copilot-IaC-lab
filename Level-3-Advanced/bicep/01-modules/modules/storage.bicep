// =============================================================================
// Storage Module - Bicep
// =============================================================================

@description('Storage account name')
@minLength(3)
@maxLength(24)
param storageAccountName string

@description('Location')
param location string

@description('Storage SKU')
@allowed(['Standard_LRS', 'Standard_GRS', 'Standard_ZRS', 'Premium_LRS'])
param sku string = 'Standard_LRS'

@description('Containers to create')
param containerNames array = []

@description('Enable blob versioning')
param enableVersioning bool = true

@description('Tags')
param tags object = {}

// Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: sku
  }
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
  }
  tags: tags
}

// Blob Services
resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    isVersioningEnabled: enableVersioning
  }
}

// Containers
resource containers 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = [
  for name in containerNames: {
    parent: blobServices
    name: name
    properties: {
      publicAccess: 'None'
    }
  }
]

// Outputs
@description('Storage account ID')
output id string = storageAccount.id

@description('Storage account name')
output name string = storageAccount.name

@description('Primary blob endpoint')
output primaryBlobEndpoint string = storageAccount.properties.primaryEndpoints.blob
