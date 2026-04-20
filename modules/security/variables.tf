variable "project_name" {
  type = string
}

variable "environment" {
  type        = string
  description = "Deployment environment name"
  default     = "dev"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where the security groups will be created"
}
