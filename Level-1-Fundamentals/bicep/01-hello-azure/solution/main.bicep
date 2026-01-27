// =============================================================================
// Level 1.1: Hello Azure - Solution
// =============================================================================
// This Bicep template creates a basic Azure resource group.
// It demonstrates subscription-level deployment and resource creation.
// =============================================================================

// Target scope for subscription-level deployment
// This allows us to create resource groups
targetScope = 'subscription'

// -----------------------------------------------------------------------------
// Resource Group
// -----------------------------------------------------------------------------
// This is the foundational resource that contains other Azure resources

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-hello-azure-dev'
  location: 'eastus'
  tags: {
    environment: 'dev'
    project: 'copilot-iac-lab'
    managed_by: 'bicep'
  }
}

// =============================================================================
// Outputs
// =============================================================================

@description('The name of the created resource group')
output resourceGroupName string = resourceGroup.name

@description('The ID of the created resource group')
output resourceGroupId string = resourceGroup.id

@description('The location of the created resource group')
output resourceGroupLocation string = resourceGroup.location
