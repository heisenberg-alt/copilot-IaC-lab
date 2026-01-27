// =============================================================================
// Level 2.1: Networking - Challenge
// =============================================================================

@description('Environment name')
@allowed(['dev', 'staging', 'prod'])
param environment string = 'dev'

@description('Azure region')
param location string = 'eastus'

@description('Workload name')
param workload string = 'network'

// TODO: Create parameter for subnets as an array of objects
// Each object should have: name, addressPrefix, and optional nsgRules


// TODO: Create variables for naming and tags


// TODO: Create Virtual Network resource


// TODO: Create subnets using a for loop


// TODO: Create NSGs using a for loop


// TODO: Create NSG rules (can use parent property or nested resources)

