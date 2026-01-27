// =============================================================================
// Level 2.2: Compute - Challenge
// =============================================================================

@description('Environment')
param environment string = 'dev'

@description('Location')
param location string = 'eastus'

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

// TODO: Create variables for naming, tags, and cloud-init script


// TODO: Create VNet and subnet


// TODO: Create public IPs using loop


// TODO: Create NICs using loop


// TODO: Create VMs using loop with cloud-init

