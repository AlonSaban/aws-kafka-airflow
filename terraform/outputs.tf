output "vpc_id" {
  value = module.networking.vpc_id
}

output "public_security_group_id" {
  value = module.security.public_security_group_id
}

output "database_security_group_id" {
  value = module.security.database_security_group_id
}

output "kafka_security_group_id" {
  value = module.security.kafka_security_group_id
}

output "airflow_security_group_id" {
  value = module.security.airflow_security_group_id
}

output "s3tables_bucket_arn" {
  value = module.s3tables.table_bucket_arn
}

output "s3tables_bucket_name" {
  value = module.s3tables.table_bucket_name
}

output "s3tables_namespace" {
  value = module.s3tables.namespace
}

output "s3tables_table_name" {
  value = module.s3tables.table_name
}

output "s3tables_table_arn" {
  value = module.s3tables.table_arn
}

output "database_instance_id" {
  value = module.database.instance_id
}

output "database_private_ip" {
  value = module.database.private_ip
}

output "database_port" {
  value = module.database.db_port
}

output "database_name" {
  value = module.database.db_name
}

output "database_username" {
  value = module.database.db_username
}

output "database_password_ssm_parameter_name" {
  value = module.database.db_password_ssm_parameter_name
}

output "kafka_instance_id" {
  value = module.kafka.instance_id
}

output "kafka_private_ip" {
  value = module.kafka.private_ip
}

output "kafka_bootstrap_servers" {
  value = module.kafka.bootstrap_servers
}

output "kafka_schema_registry_url" {
  value = module.kafka.schema_registry_url
}

output "kafka_connect_rest_url" {
  value = module.kafka.connect_rest_url
}

output "kafka_topic_name" {
  value = module.kafka.topic_name
}

output "airflow_instance_id" {
  value = module.airflow.instance_id
}

output "airflow_private_ip" {
  value = module.airflow.private_ip
}

output "airflow_web_url" {
  value = module.airflow.web_url
}

output "airflow_admin_password_ssm_parameter_name" {
  value = module.airflow.admin_password_ssm_parameter_name
}
