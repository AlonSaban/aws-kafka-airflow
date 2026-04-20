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

  project_name   = var.project_name
  environment    = var.environment
  vpc_id         = module.networking.vpc_id
  vpc_cidr_block = module.networking.vpc_cidr_block
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
  vpc_security_group_ids = [module.security.private_security_group_id]
  vpc_cidr_block         = module.networking.vpc_cidr_block
  instance_type          = var.database_instance_type
  volume_size            = var.database_volume_size
  db_name                = var.database_name
  db_username            = var.database_username
}

module "kafka" {
  source = "../modules/kafka"

  project_name           = var.project_name
  environment            = var.environment
  subnet_id              = module.networking.private_subnet_ids[0]
  vpc_security_group_ids = [module.security.private_security_group_id]
  instance_type          = var.kafka_instance_type
  volume_size            = var.kafka_volume_size
  topic_name             = var.kafka_topic_name
}
