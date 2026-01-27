// =============================================================================
// Networking Module - Bicep
// =============================================================================

@description('VNet name')
param vnetName string

@description('Location')
param location string

@description('Address space')
param addressSpace array = ['10.0.0.0/16']

@description('Subnets configuration')
param subnets array = []

@description('Tags')
param tags object = {}

// Virtual Network with Subnets
resource vnet 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: addressSpace
    }
    subnets: [
      for subnet in subnets: {
        name: subnet.name
        properties: {
          addressPrefix: subnet.addressPrefix
          serviceEndpoints: subnet.?serviceEndpoints ?? []
        }
      }
    ]
  }
  tags: tags
}

// Outputs
@description('VNet ID')
output id string = vnet.id

@description('VNet name')
output name string = vnet.name

@description('Subnet IDs')
output subnetIds array = [for (subnet, i) in subnets: vnet.properties.subnets[i].id]
