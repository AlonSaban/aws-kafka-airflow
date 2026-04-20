module "networking" {
  source = "../modules/networking"

  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
  environment          = var.environment
}

module "security" {
  source = "../modules/security"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.networking.vpc_id
}

module "s3tables" {
  source = "../modules/s3tables"

  table_bucket_name = var.s3tables_bucket_name
  namespace         = var.s3tables_namespace
  table_name        = var.s3tables_table_name
  environment       = var.environment
}

module "database" {
  source = "../modules/database"

  project_name           = var.project_name
  environment            = var.environment
  subnet_id              = module.networking.private_subnet_ids[0]
  vpc_security_group_ids = [module.security.database_security_group_id]
  vpc_cidr_block         = module.networking.vpc_cidr_block
  instance_type          = var.database_instance_type
  volume_size            = var.database_volume_size
  db_name                = var.database_name
  db_username            = var.database_username
}

module "kafka" {
  source = "../modules/kafka"

  aws_region                     = var.aws_region
  db_host                        = module.database.private_ip
  db_name                        = module.database.db_name
  db_password_ssm_parameter_name = module.database.db_password_ssm_parameter_name
  db_port                        = module.database.db_port
  db_username                    = module.database.db_username
  project_name                   = var.project_name
  environment                    = var.environment
  subnet_id                      = module.networking.private_subnet_ids[0]
  vpc_security_group_ids         = [module.security.kafka_security_group_id]
  instance_type                  = var.kafka_instance_type
  volume_size                    = var.kafka_volume_size
  topic_name                     = var.kafka_topic_name
}

module "airflow" {
  source = "../modules/airflow"

  project_name            = var.project_name
  environment             = var.environment
  aws_region              = var.aws_region
  subnet_id               = module.networking.private_subnet_ids[0]
  vpc_security_group_ids  = [module.security.airflow_security_group_id]
  instance_type           = var.airflow_instance_type
  volume_size             = var.airflow_volume_size
  kafka_bootstrap_servers = module.kafka.bootstrap_servers
  kafka_topic_name        = module.kafka.topic_name
  s3tables_bucket_arn     = module.s3tables.table_bucket_arn
  s3tables_table_arn      = module.s3tables.table_arn
  s3tables_namespace      = module.s3tables.namespace
  s3tables_table_name     = module.s3tables.table_name
}

module "trino" {
  source = "../modules/trino"

  project_name           = var.project_name
  environment            = var.environment
  aws_region             = var.aws_region
  subnet_id              = module.networking.private_subnet_ids[0]
  vpc_security_group_ids = [module.security.trino_security_group_id]
  instance_type          = var.trino_instance_type
  volume_size            = var.trino_volume_size
  trino_version          = var.trino_version
  s3tables_bucket_arn    = module.s3tables.table_bucket_arn
  s3tables_table_arn     = module.s3tables.table_arn
  s3tables_namespace     = module.s3tables.namespace
  s3tables_table_name    = module.s3tables.table_name
}
