# =============================================================================
# Terraform Variables
# =============================================================================

environment = "dev"
location    = "eastus"
workload    = "network"

vnet_address_space = ["10.0.0.0/16"]

subnets = {
  web = {
    address_prefix    = "10.0.1.0/24"
    service_endpoints = []
  }
  app = {
    address_prefix    = "10.0.2.0/24"
    service_endpoints = ["Microsoft.Storage"]
  }
  db = {
    address_prefix    = "10.0.3.0/24"
    service_endpoints = ["Microsoft.Sql"]
  }
}
