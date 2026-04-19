module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.project_name
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Name        = var.project_name
    Environment = var.environment
    Terraform   = "true"
  }
}
