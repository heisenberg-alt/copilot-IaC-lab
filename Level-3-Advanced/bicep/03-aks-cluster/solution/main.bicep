// =============================================================================
// Level 3.3: AKS Cluster - Bicep Solution
// =============================================================================

@description('Environment')
param environment string = 'dev'

@description('Location')
param location string = 'eastus'

@description('Workload')
param workload string = 'aks'

var commonTags = {
  environment: environment
  project: workload
  managed_by: 'bicep'
}

// Container Registry
resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: 'acr${workload}${environment}${uniqueString(resourceGroup().id)}'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    adminUserEnabled: false
  }
  tags: commonTags
}

// AKS Cluster
resource aks 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: 'aks-${workload}-${environment}'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: 'aks-${workload}-${environment}'
    agentPoolProfiles: [
      {
        name: 'system'
        count: 2
        vmSize: 'Standard_DS2_v2'
        osType: 'Linux'
        mode: 'System'
        enableAutoScaling: true
        minCount: 1
        maxCount: 3
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      loadBalancerSku: 'standard'
    }
  }
  tags: commonTags
}

// User node pool
resource userPool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aks
  name: 'user'
  properties: {
    count: 2
    vmSize: 'Standard_DS2_v2'
    osType: 'Linux'
    mode: 'User'
    enableAutoScaling: true
    minCount: 1
    maxCount: 5
  }
}

// ACR Pull role for AKS
resource acrPullRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acr.id, aks.id, 'acrpull')
  scope: acr
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
    principalId: aks.properties.identityProfile.kubeletidentity.objectId
    principalType: 'ServicePrincipal'
  }
}

// Outputs
output aksClusterName string = aks.name
output acrLoginServer string = acr.properties.loginServer
output getCredentialsCommand string = 'az aks get-credentials --resource-group ${resourceGroup().name} --name ${aks.name}'
