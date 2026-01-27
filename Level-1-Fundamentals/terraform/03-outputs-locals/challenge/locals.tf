# =============================================================================
# Level 1.3: Locals - Challenge
# =============================================================================
#
# CHALLENGE: Define local values for naming and tagging
#
# Use GitHub Copilot to help you complete the TODOs!
# =============================================================================

locals {
  # TODO: Create name_prefix combining workload, environment, and location
  # Format: {workload}-{environment}-{location}
  name_prefix = ""

  # TODO: Create storage_name (lowercase, no hyphens, max 24 chars)
  storage_name = ""

  # TODO: Create common_tags map with:
  # - environment
  # - project (use workload)
  # - managed_by = "terraform"
  common_tags = {}

  # TODO: Create container_names list with: "data", "logs", "backups"
  container_names = []
}
