locals {
  common_tags = {
    Project   = var.project_name
    ManagedBy = "Terraform"
  }

  name_prefix = "${var.project_name}-${var.environment}"
}