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
