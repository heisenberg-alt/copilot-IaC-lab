// =============================================================================
// Level 1.2: Storage Account with Parameters - Solution
// =============================================================================

// -----------------------------------------------------------------------------
// Parameters
// -----------------------------------------------------------------------------

@description('The deployment environment')
@allowed(['dev', 'staging', 'prod'])
param environment string = 'dev'

@description('The Azure region where resources will be created')
param location string = 'eastus'

@description('The name of the project (used in resource naming)')
@minLength(3)
@maxLength(20)
param projectName string

// -----------------------------------------------------------------------------
// Variables
// -----------------------------------------------------------------------------

var commonTags = {
  environment: environment
  project: projectName
  managed_by: 'bicep'
  created_by: 'copilot-iac-lab'
}

// Storage account name: lowercase, no hyphens, max 24 characters
var storageAccountName = toLower(take(replace('st${projectName}${environment}', '-', ''), 24))

// -----------------------------------------------------------------------------
// Resources
// -----------------------------------------------------------------------------

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
    allowBlobPublicAccess: false
  }
  tags: commonTags
}

// Enable blob versioning
resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    isVersioningEnabled: true
  }
}

// -----------------------------------------------------------------------------
// Outputs
// -----------------------------------------------------------------------------

@description('The name of the storage account')
output storageAccountName string = storageAccount.name

@description('The ID of the storage account')
output storageAccountId string = storageAccount.id

@description('The primary blob endpoint')
output primaryBlobEndpoint string = storageAccount.properties.primaryEndpoints.blob
