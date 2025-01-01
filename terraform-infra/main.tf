provider "aws" {
  region = "ap-south-1"
}

module "vpc" {
  source              = "./modules/vpc"
  vpc_cidr            = "10.0.0.0/16"
  vpc_name            = "my-vpc"
  public_subnet_cidr  = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
  public_az           = "ap-south-1a"
  private_az          = "ap-south-1b"
  public_subnet_name  = "my-public-subnet"
  private_subnet_name = "my-private-subnet"
  igw_name            = "my-internet-gateway"
  public_rt_name      = "my-public-route-table"
}

module "ec2" {
  source          = "./modules/ec2"
  vpc_id          = module.vpc.vpc_id
  subnet_id       = module.vpc.public_subnet_id
  ami             = "ami-0dee22c13ea7a9a67"
  instance_type   = "t2.micro"
  key_name        = "aws-manju"
  sg_name         = "ec2-sg"
  instance_name   = "my-ec2-instance"
}
