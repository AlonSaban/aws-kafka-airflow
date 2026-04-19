variable "table_bucket_name" {
  type        = string
  description = "Name of the S3 table bucket"
}

variable "namespace" {
  type        = string
  description = "S3 Tables namespace name"
}

variable "table_name" {
  type        = string
  description = "Iceberg table name"
}

variable "environment" {
  type        = string
  description = "Deployment environment name"
  default     = "dev"
}
