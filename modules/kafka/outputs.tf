output "instance_id" {
  description = "EC2 instance ID of the Kafka host"
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "Private IP of the Kafka host"
  value       = aws_instance.this.private_ip
}

output "bootstrap_servers" {
  description = "Kafka bootstrap server address"
  value       = "${aws_instance.this.private_ip}:9092"
}

output "schema_registry_url" {
  description = "Internal Schema Registry URL"
  value       = "http://${aws_instance.this.private_ip}:8081"
}

output "connect_rest_url" {
  description = "Internal Kafka Connect REST URL"
  value       = "http://${aws_instance.this.private_ip}:8083"
}

output "iam_instance_profile_name" {
  description = "IAM instance profile attached to the Kafka instance"
  value       = aws_iam_instance_profile.kafka.name
}

output "topic_name" {
  description = "Kafka topic created for CDC events"
  value       = var.topic_name
}
