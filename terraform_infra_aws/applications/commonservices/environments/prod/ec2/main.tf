module "ec2" {
  source = "../../../../../modules/ec2"
  environment = var.environment
  project_name = var.project_name
  aws_region = var.aws_region
  # Referencing VPC output from remote state
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  public_subnet_ids = data.terraform_remote_state.vpc.outputs.public_subnet_ids[*]
  associate_public_ip_address = var.associate_public_ip_address
  keypairname = var.keypairname
  instanceType = var.instanceType
  bastionhost_iamrole_name = var.bastionhost_iamrole_name
  bastionhost_iaminstanceprofile_name = var.bastionhost_iaminstanceprofile_name
  bastionsg_ingress_rules = var.bastionsg_ingress_rules
  ebs_rootvol_size = var.ebs_rootvol_size
  ebs_vol_type = var.ebs_vol_type
  aws_access_key_id = var.aws_access_key_id
  aws_secret_access_key = var.aws_secret_access_key
  eks_cluster_name = var.eks_cluster_name
  ekslbcontroller_iamrolename = var.ekslbcontroller_iamrolename
  ekslbcontroller_serviceaccountname = var.ekslbcontroller_serviceaccountname
  ekslbcontroller_iampolicyarn = data.terraform_remote_state.eks.outputs.ekslbcontroller_iampolicyarn
  depends_on = [
    data.terraform_remote_state.vpc,
    data.terraform_remote_state.eks
  ]
}

# Data source to retrieve the remote state of the VPC
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "commonservices1"
    key    = "prod/vpc/terraform.tfstate"
    region = "ap-south-1"
  }
}
data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "commonservices1"
    key    = "prod/eks/terraform.tfstate"
    region = "ap-south-1"
  }
}


