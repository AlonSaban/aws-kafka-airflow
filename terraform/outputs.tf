output "vpc_id" {
  value = module.networking.vpc_id
}

output "public_security_group_id" {
  value = module.security.public_security_group_id
}

output "private_security_group_id" {
  value = module.security.private_security_group_id
}
