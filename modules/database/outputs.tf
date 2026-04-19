output "instance_id" {
  description = "EC2 instance ID of the database host"
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "Private IP of the database host"
  value       = aws_instance.this.private_ip
}

output "db_port" {
  description = "PostgreSQL port"
  value       = 5432
}

output "db_name" {
  description = "Application database name"
  value       = var.db_name
}

output "db_username" {
  description = "Database username used by CDC tooling"
  value       = var.db_username
}

output "db_password_ssm_parameter_name" {
  description = "SSM parameter name containing the generated database password"
  value       = aws_ssm_parameter.db_password.name
}

output "iam_instance_profile_name" {
  description = "IAM instance profile attached to the database instance"
  value       = aws_iam_instance_profile.database.name
}
