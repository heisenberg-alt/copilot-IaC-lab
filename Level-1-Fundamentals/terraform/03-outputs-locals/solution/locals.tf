# =============================================================================
# Level 1.3: Locals - Solution
# =============================================================================

locals {
  # Naming prefix for resources
  name_prefix = "${var.workload}-${var.environment}-${var.location}"

  # Storage account name (lowercase, no hyphens, max 24 chars)
  storage_name = lower(substr(replace("st${var.workload}${var.environment}", "-", ""), 0, 24))

  # Key Vault name (must be globally unique, 3-24 chars)
  key_vault_name = substr("kv-${var.workload}-${var.environment}", 0, 24)

  # Common tags for all resources
  common_tags = {
    environment = var.environment
    project     = var.workload
    managed_by  = "terraform"
    created_by  = "copilot-iac-lab"
  }

  # Container names to create
  container_names = ["data", "logs", "backups"]
}
