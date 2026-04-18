output "vpc_id" {
  value = module.networking.vpc_id
}

output "kafka_private_ip" {
  value = module.kafka.private_ip
}