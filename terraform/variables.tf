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

variable "database_instance_type" {
  type        = string
  description = "EC2 instance type for the PostgreSQL source database"
  default     = "t3.medium"
}

variable "database_volume_size" {
  type        = number
  description = "Root volume size in GiB for the PostgreSQL instance"
  default     = 30
}

variable "database_name" {
  type        = string
  description = "PostgreSQL database name"
  default     = "orders_db"
}

variable "database_username" {
  type        = string
  description = "PostgreSQL username for CDC access"
  default     = "cdc_user"
}

variable "kafka_instance_type" {
  type        = string
  description = "EC2 instance type for the Kafka host"
  default     = "t3.large"
}

variable "kafka_volume_size" {
  type        = number
  description = "Root volume size in GiB for the Kafka instance"
  default     = 80
}

variable "kafka_topic_name" {
  type        = string
  description = "Kafka topic name for CDC events"
  default     = "cdc.orders"
}

variable "airflow_instance_type" {
  type        = string
  description = "EC2 instance type for the Airflow host"
  default     = "t3.large"
}

variable "airflow_volume_size" {
  type        = number
  description = "Root volume size in GiB for the Airflow instance"
  default     = 50
}
