// =============================================================================
// Level 2.2: Compute - Solution
// =============================================================================

@description('Environment')
param environment string = 'dev'

@description('Location')
param location string = 'eastus'

@description('Workload name')
param workload string = 'compute'

@description('Number of VMs')
@minValue(1)
@maxValue(5)
param vmCount int = 2

@description('VM Size')
param vmSize string = 'Standard_B2s'

@description('Admin username')
param adminUsername string = 'azureadmin'

@description('SSH public key')
@secure()
param adminSshKey string

// -----------------------------------------------------------------------------
// Variables
// -----------------------------------------------------------------------------
var namePrefix = '${workload}-${environment}'
var commonTags = {
  environment: environment
  project: workload
  managed_by: 'bicep'
}

var cloudInit = '''
#!/bin/bash
apt-get update
apt-get install -y nginx
echo "<h1>Hello from $(hostname)</h1>" > /var/www/html/index.html
systemctl start nginx
systemctl enable nginx
'''

// -----------------------------------------------------------------------------
// Networking
// -----------------------------------------------------------------------------
resource vnet 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: 'vnet-${namePrefix}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
    subnets: [
      {
        name: 'snet-web'
        properties: {
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
  tags: commonTags
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: 'nsg-web-${environment}'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-HTTP'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'Allow-SSH'
        properties: {
          priority: 110
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
  tags: commonTags
}

// -----------------------------------------------------------------------------
// Public IPs
// -----------------------------------------------------------------------------
resource publicIps 'Microsoft.Network/publicIPAddresses@2024-01-01' = [
  for i in range(0, vmCount): {
    name: 'pip-web-${i + 1}-${environment}'
    location: location
    sku: {
      name: 'Standard'
    }
    properties: {
      publicIPAllocationMethod: 'Static'
    }
    tags: commonTags
  }
]

// -----------------------------------------------------------------------------
// Network Interfaces
// -----------------------------------------------------------------------------
resource nics 'Microsoft.Network/networkInterfaces@2024-01-01' = [
  for i in range(0, vmCount): {
    name: 'nic-web-${i + 1}-${environment}'
    location: location
    properties: {
      ipConfigurations: [
        {
          name: 'ipconfig1'
          properties: {
            subnet: {
              id: vnet.properties.subnets[0].id
            }
            privateIPAllocationMethod: 'Dynamic'
            publicIPAddress: {
              id: publicIps[i].id
            }
          }
        }
      ]
    }
    tags: commonTags
  }
]

// -----------------------------------------------------------------------------
// Virtual Machines
// -----------------------------------------------------------------------------
resource vms 'Microsoft.Compute/virtualMachines@2024-03-01' = [
  for i in range(0, vmCount): {
    name: 'vm-web-${i + 1}-${environment}'
    location: location
    properties: {
      hardwareProfile: {
        vmSize: vmSize
      }
      osProfile: {
        computerName: 'vm-web-${i + 1}'
        adminUsername: adminUsername
        customData: base64(cloudInit)
        linuxConfiguration: {
          disablePasswordAuthentication: true
          ssh: {
            publicKeys: [
              {
                path: '/home/${adminUsername}/.ssh/authorized_keys'
                keyData: adminSshKey
              }
            ]
          }
        }
      }
      storageProfile: {
        imageReference: {
          publisher: 'Canonical'
          offer: '0001-com-ubuntu-server-jammy'
          sku: '22_04-lts-gen2'
          version: 'latest'
        }
        osDisk: {
          name: 'osdisk-web-${i + 1}'
          createOption: 'FromImage'
          managedDisk: {
            storageAccountType: 'Standard_LRS'
          }
        }
      }
      networkProfile: {
        networkInterfaces: [
          {
            id: nics[i].id
          }
        ]
      }
    }
    tags: commonTags
  }
]

// -----------------------------------------------------------------------------
// Outputs
// -----------------------------------------------------------------------------
@description('VM names')
output vmNames array = [for i in range(0, vmCount): vms[i].name]

@description('Public IP addresses')
output publicIpAddresses array = [for i in range(0, vmCount): publicIps[i].properties.ipAddress]

@description('Web URLs')
output webUrls array = [for i in range(0, vmCount): 'http://${publicIps[i].properties.ipAddress}']
