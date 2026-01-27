using './main.bicep'

param environment = 'dev'
param location = 'eastus'
param workload = 'network'
param vnetAddressPrefix = '10.0.0.0/16'
param subnets = [
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
