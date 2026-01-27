// =============================================================================
// Level 1.3: Outputs and Variables - Challenge
// =============================================================================
//
// CHALLENGE: Create resources with proper variables and outputs
//
// Use GitHub Copilot to help you complete the TODOs!
// =============================================================================

// Parameters
@description('The deployment environment')
@allowed(['dev', 'staging', 'prod'])
param environment string = 'dev'

@description('The Azure region')
param location string = 'eastus'

@description('The workload name')
param workload string = 'iaclab'

// TODO: Create variables for:
// - namePrefix: combining workload, environment, and location
// - storageAccountName: lowercase, no hyphens, max 24 chars
// - keyVaultName: max 24 chars
// - commonTags: object with environment, project, managed_by
// - containerNames: array with 'data', 'logs', 'backups'


// TODO: Create a storage account resource


// TODO: Create blob services with versioning enabled


// TODO: Create storage containers using a for loop with containerNames


// TODO: Create a Key Vault resource


// TODO: Create outputs for:
// - storageAccountId
// - storageAccountName
// - primaryBlobEndpoint
// - keyVaultId
// - keyVaultUri
// - containerNames (the array)

