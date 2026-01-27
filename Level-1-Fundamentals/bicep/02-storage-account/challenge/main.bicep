// =============================================================================
// Level 1.2: Storage Account with Parameters - Challenge
// =============================================================================
//
// CHALLENGE: Create an Azure Storage Account using parameters
//
// Use GitHub Copilot to help you complete the TODOs!
// =============================================================================

// TODO: Add parameter "environment" with:
// - @description decorator
// - @allowed decorator for ['dev', 'staging', 'prod']
// - default value: 'dev'


// TODO: Add parameter "location" with:
// - @description decorator
// - default value: 'eastus'


// TODO: Add parameter "projectName" with:
// - @description decorator
// - @minLength(3) and @maxLength(20) decorators
// - no default (required)


// TODO: Create variables for:
// - commonTags (object with environment, project, managed_by)
// - storageAccountName (lowercase, no hyphens, max 24 chars)


// TODO: Create a storage account resource with:
// - Standard_LRS SKU
// - StorageV2 kind
// - Hot access tier
// - HTTPS only
// - TLS 1.2 minimum
// - Blob versioning enabled (using properties.blob.isVersioningEnabled in blobServices)

