output "public_security_group_id" {
  description = "ID of the public security group"
  value       = aws_security_group.public.id
}

output "database_security_group_id" {
  description = "ID of the database security group"
  value       = aws_security_group.database.id
}

output "kafka_security_group_id" {
  description = "ID of the Kafka security group"
  value       = aws_security_group.kafka.id
}

output "airflow_security_group_id" {
  description = "ID of the Airflow security group"
  value       = aws_security_group.airflow.id
}
