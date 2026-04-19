variable "project_name" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "il-central-1"
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "azs" {
  type = list(string)
}

variable "environment" {
  type        = string
  description = "Deployment environment name"
  default     = "dev"
}

variable "s3tables_bucket_name" {
  type        = string
  description = "Name of the S3 Tables bucket"
}

variable "s3tables_namespace" {
  type        = string
  description = "Namespace for the S3 Tables Iceberg catalog"
}

variable "s3tables_table_name" {
  type        = string
  description = "Name of the S3 Tables Iceberg table"
}
