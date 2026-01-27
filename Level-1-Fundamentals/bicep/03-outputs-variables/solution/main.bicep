// =============================================================================
// Level 1.3: Outputs and Variables - Solution
// =============================================================================

// -----------------------------------------------------------------------------
// Parameters
// -----------------------------------------------------------------------------

@description('The deployment environment')
@allowed(['dev', 'staging', 'prod'])
param environment string = 'dev'

@description('The Azure region')
param location string = 'eastus'

@description('The workload name')
param workload string = 'iaclab'

// -----------------------------------------------------------------------------
// Variables
// -----------------------------------------------------------------------------

var namePrefix = '${workload}-${environment}-${location}'
var storageAccountName = toLower(take(replace('st${workload}${environment}', '-', ''), 24))
var keyVaultName = take('kv-${workload}-${environment}', 24)

var commonTags = {
  environment: environment
  project: workload
  managed_by: 'bicep'
  created_by: 'copilot-iac-lab'
}

var containerNames = ['data', 'logs', 'backups']

// -----------------------------------------------------------------------------
// Resources
// -----------------------------------------------------------------------------

// Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
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

// Blob Services with versioning
resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    isVersioningEnabled: true
  }
}

// Storage Containers (using loop)
resource containers 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = [
  for name in containerNames: {
    parent: blobServices
    name: name
    properties: {
      publicAccess: 'None'
    }
  }
]

// Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: false
    enableRbacAuthorization: true
  }
  tags: commonTags
}

// -----------------------------------------------------------------------------
// Outputs
// -----------------------------------------------------------------------------

@description('The ID of the storage account')
output storageAccountId string = storageAccount.id

@description('The name of the storage account')
output storageAccountName string = storageAccount.name

@description('The primary blob endpoint')
output primaryBlobEndpoint string = storageAccount.properties.primaryEndpoints.blob

@description('The ID of the Key Vault')
output keyVaultId string = keyVault.id

@description('The URI of the Key Vault')
output keyVaultUri string = keyVault.properties.vaultUri

@description('The name of the Key Vault')
output keyVaultName string = keyVault.name

@description('The names of the created containers')
output createdContainerNames array = containerNames

@description('Container URLs')
output containerUrls array = [
  for name in containerNames: '${storageAccount.properties.primaryEndpoints.blob}${name}'
]
