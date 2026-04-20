output "instance_id" {
  description = "EC2 instance ID of the Trino host"
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "Private IP of the Trino host"
  value       = aws_instance.this.private_ip
}

output "web_url" {
  description = "Internal Trino UI URL"
  value       = "http://${aws_instance.this.private_ip}:8080"
}
