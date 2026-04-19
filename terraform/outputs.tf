output "vpc_id" {
  value = module.networking.vpc_id
}

output "public_security_group_id" {
  value = module.security.public_security_group_id
}

output "private_security_group_id" {
  value = module.security.private_security_group_id
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
