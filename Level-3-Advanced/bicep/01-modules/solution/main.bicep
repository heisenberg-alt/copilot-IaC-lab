// =============================================================================
// Level 3.1: Bicep Modules - Solution
// =============================================================================

@description('Environment')
param environment string = 'dev'

@description('Location')
param location string = 'eastus'

@description('Workload name')
param workload string = 'modular'

// Variables
var commonTags = {
  environment: environment
  project: workload
  managed_by: 'bicep'
}

// Networking Module
module networking '../modules/networking.bicep' = {
  name: 'networking'
  params: {
    vnetName: 'vnet-${workload}-${environment}'
    location: location
    addressSpace: ['10.0.0.0/16']
    subnets: [
      {
        name: 'snet-web'
        addressPrefix: '10.0.1.0/24'
        serviceEndpoints: [
          { service: 'Microsoft.Storage' }
        ]
      }
      {
        name: 'snet-app'
        addressPrefix: '10.0.2.0/24'
      }
    ]
    tags: commonTags
  }
}

// Storage Module
module storage '../modules/storage.bicep' = {
  name: 'storage'
  params: {
    storageAccountName: 'st${workload}${environment}001'
    location: location
    sku: 'Standard_LRS'
    containerNames: ['data', 'logs', 'backups']
    enableVersioning: true
    tags: commonTags
  }
}

// Outputs
output vnetId string = networking.outputs.id
output subnetIds array = networking.outputs.subnetIds
output storageAccountName string = storage.outputs.name
output storageBlobEndpoint string = storage.outputs.primaryBlobEndpoint
