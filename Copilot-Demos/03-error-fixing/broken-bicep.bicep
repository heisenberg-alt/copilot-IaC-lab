// =============================================================================
// Broken Bicep - Error Fixing Demo
// =============================================================================
// This file has INTENTIONAL ERRORS for demonstration!
// Ask Copilot to fix them.
// =============================================================================

// ERROR 1: Wrong decorator syntax
@Description('Environment name')
param environment string = 'dev'

// ERROR 2: Invalid allowed values (missing quotes)
@allowed([dev, staging, prod])
param tier string = 'dev'

// ERROR 3: Wrong parameter type
param vmCount int = 'two'

// ERROR 4: Typo in resource type
resource storageAccount 'Microsoft.Storage/storageAcconts@2023-05-01' = {
  name: 'stbroken123'
  location: 'eastus'
  // ERROR 5: Wrong property structure
  sku: 'Standard_LRS'
  kind: 'StorageV2'
}

// ERROR 6: Wrong API version (too old, doesn't exist)
resource vnet 'Microsoft.Network/virtualNetworks@2015-01-01' = {
  name: 'vnet-demo'
  location: 'eastus'
  properties: {
    addressSpace: {
      // ERROR 7: Wrong property name
      addressPrefix: ['10.0.0.0/16']
    }
  }
}

// ERROR 8: Invalid reference
output storageEndpoint string = storage.properties.primaryEndpoints.blob

// ERROR 9: Missing required property
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: 'kv-demo'
  location: 'eastus'
  // Missing properties block with sku and tenantId!
}
