// =============================================================================
// Level 2.1: Networking - Solution
// =============================================================================

@description('Environment name')
@allowed(['dev', 'staging', 'prod'])
param environment string = 'dev'

@description('Azure region')
param location string = 'eastus'

@description('Workload name')
param workload string = 'network'

@description('VNet address space')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('Subnet configurations')
param subnets array = [
  {
    name: 'web'
    addressPrefix: '10.0.1.0/24'
  }
  {
    name: 'app'
    addressPrefix: '10.0.2.0/24'
  }
  {
    name: 'db'
    addressPrefix: '10.0.3.0/24'
  }
]

// -----------------------------------------------------------------------------
// Variables
// -----------------------------------------------------------------------------
var namePrefix = '${workload}-${environment}'
var commonTags = {
  environment: environment
  project: workload
  managed_by: 'bicep'
}

// -----------------------------------------------------------------------------
// Virtual Network
// -----------------------------------------------------------------------------
resource vnet 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: 'vnet-${namePrefix}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [vnetAddressPrefix]
    }
    subnets: [
      for subnet in subnets: {
        name: 'snet-${subnet.name}'
        properties: {
          addressPrefix: subnet.addressPrefix
          networkSecurityGroup: {
            id: nsgs[indexOf(map(subnets, s => s.name), subnet.name)].id
          }
        }
      }
    ]
  }
  tags: commonTags
}

// -----------------------------------------------------------------------------
// Network Security Groups
// -----------------------------------------------------------------------------
resource nsgs 'Microsoft.Network/networkSecurityGroups@2024-01-01' = [
  for subnet in subnets: {
    name: 'nsg-${subnet.name}-${environment}'
    location: location
    properties: {
      securityRules: []
    }
    tags: commonTags
  }
]

// Web NSG Rules
resource webHttpRule 'Microsoft.Network/networkSecurityGroups/securityRules@2024-01-01' = {
  parent: nsgs[0] // web NSG
  name: 'Allow-HTTP'
  properties: {
    priority: 100
    direction: 'Inbound'
    access: 'Allow'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '80'
    sourceAddressPrefix: 'Internet'
    destinationAddressPrefix: '*'
  }
}

resource webHttpsRule 'Microsoft.Network/networkSecurityGroups/securityRules@2024-01-01' = {
  parent: nsgs[0] // web NSG
  name: 'Allow-HTTPS'
  properties: {
    priority: 110
    direction: 'Inbound'
    access: 'Allow'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '443'
    sourceAddressPrefix: 'Internet'
    destinationAddressPrefix: '*'
  }
}

// App NSG Rules
resource appFromWebRule 'Microsoft.Network/networkSecurityGroups/securityRules@2024-01-01' = {
  parent: nsgs[1] // app NSG
  name: 'Allow-From-Web'
  properties: {
    priority: 100
    direction: 'Inbound'
    access: 'Allow'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '8080'
    sourceAddressPrefix: subnets[0].addressPrefix
    destinationAddressPrefix: '*'
  }
}

// DB NSG Rules
resource dbFromAppRule 'Microsoft.Network/networkSecurityGroups/securityRules@2024-01-01' = {
  parent: nsgs[2] // db NSG
  name: 'Allow-From-App'
  properties: {
    priority: 100
    direction: 'Inbound'
    access: 'Allow'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '1433'
    sourceAddressPrefix: subnets[1].addressPrefix
    destinationAddressPrefix: '*'
  }
}

// -----------------------------------------------------------------------------
// Outputs
// -----------------------------------------------------------------------------
@description('VNet ID')
output vnetId string = vnet.id

@description('VNet name')
output vnetName string = vnet.name

@description('Subnet IDs')
output subnetIds array = [for (subnet, i) in subnets: vnet.properties.subnets[i].id]

@description('NSG IDs')
output nsgIds array = [for (subnet, i) in subnets: nsgs[i].id]
