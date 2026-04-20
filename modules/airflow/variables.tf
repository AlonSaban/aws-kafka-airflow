variable "project_name" {
  type = string
}

variable "environment" {
  type        = string
  description = "Deployment environment name"
  default     = "dev"
}

variable "aws_region" {
  type        = string
  description = "AWS region where the Airflow host is deployed"
}

variable "subnet_id" {
  type        = string
  description = "Private subnet ID where the Airflow instance will be deployed"
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "Security groups to attach to the Airflow instance"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for the Airflow host"
  default     = "t3.large"
}

variable "volume_size" {
  type        = number
  description = "Root EBS volume size in GiB"
  default     = 50
}

variable "kafka_bootstrap_servers" {
  type        = string
  description = "Kafka bootstrap server string"
}

variable "kafka_topic_name" {
  type        = string
  description = "Kafka topic Airflow should consume from"
}

variable "s3tables_bucket_arn" {
  type        = string
  description = "ARN of the S3 Tables bucket"
}

variable "s3tables_table_arn" {
  type        = string
  description = "ARN of the S3 Tables table"
}

variable "s3tables_namespace" {
  type        = string
  description = "Namespace of the S3 Tables Iceberg table"
}

variable "s3tables_table_name" {
  type        = string
  description = "Name of the S3 Tables Iceberg table"
}
