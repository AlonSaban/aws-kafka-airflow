variable "project_name" {
  type = string
}

variable "environment" {
  type        = string
  description = "Deployment environment name"
  default     = "dev"
}

variable "subnet_id" {
  type        = string
  description = "Private subnet ID where the database instance will be deployed"
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "Security groups to attach to the database instance"
}

variable "vpc_cidr_block" {
  type        = string
  description = "VPC CIDR allowed to reach PostgreSQL"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for the database host"
  default     = "t3.medium"
}

variable "volume_size" {
  type        = number
  description = "Root EBS volume size in GiB"
  default     = 30
}

variable "db_name" {
  type        = string
  description = "Application database name"
  default     = "orders_db"
}

variable "db_username" {
  type        = string
  description = "Database username used by CDC tooling"
  default     = "cdc_user"
}
