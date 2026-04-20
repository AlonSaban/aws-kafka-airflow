output "instance_id" {
  description = "EC2 instance ID of the Airflow host"
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "Private IP of the Airflow host"
  value       = aws_instance.this.private_ip
}

output "web_url" {
  description = "Internal Airflow UI URL"
  value       = "http://${aws_instance.this.private_ip}:8080"
}

output "admin_password_ssm_parameter_name" {
  description = "SSM parameter containing the Airflow admin password"
  value       = aws_ssm_parameter.airflow_admin_password.name
}
