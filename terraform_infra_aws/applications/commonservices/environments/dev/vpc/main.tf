
module "vpc" {
  source = "../../../../../modules/vpc"
  environment = var.environment
  project_name = var.project_name
  vpc_cidr_block = var.vpc_cidr_block
  public_subnet_cidr_blocks = var.public_subnet_cidr_blocks
  private_subnet_cidr_blocks = var.private_subnet_cidr_blocks
  availability_zones = var.availability_zones
  eks_cluster_name = var.eks_cluster_name
  public_subnet_additionaltags = var.public_subnet_additionaltags
  private_subnet_additionaltags = var.private_subnet_additionaltags
}

