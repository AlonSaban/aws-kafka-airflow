module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = project_name
  cidr = "10.0.0.0/16"

  azs             = var.azs
  private_subnets = var.private_subnet_cidrs
  public_subnets  = public_subnet_cidrs

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
  }
}