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
  description = "Private subnet ID where the Kafka instance will be deployed"
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "Security groups to attach to the Kafka instance"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for the Kafka host"
  default     = "t3.large"
}

variable "volume_size" {
  type        = number
  description = "Root EBS volume size in GiB"
  default     = 80
}

variable "topic_name" {
  type        = string
  description = "Kafka topic to create for CDC events"
  default     = "cdc.orders"
}
