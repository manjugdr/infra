data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "commonservices1"
    key    = "prod/vpc/terraform.tfstate"
    region = "ap-south-1"
  }
}

module "eks" {
  source = "../../../../../modules/eks"
  environment = var.environment
  project_name = var.project_name
  aws_region = var.aws_region
  eks_cluster_name = var.eks_cluster_name
  eks_cluster_version = var.eks_cluster_version  
  vpcconfig_endpoint_privateaccess = var.vpcconfig_endpoint_privateaccess
  vpcconfig_endpoint_publicaccess = var.vpcconfig_endpoint_publicaccess

  eks_cluster_rolename = var.eks_cluster_rolename
  eks_node_rolename = var.eks_node_rolename
  
  # Referencing VPC output from remote state
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids_for_eks_cluster = concat(data.terraform_remote_state.vpc.outputs.private_subnet_ids, data.terraform_remote_state.vpc.outputs.public_subnet_ids)
  subnet_ids_for_eks_cluster_node_group = data.terraform_remote_state.vpc.outputs.private_subnet_ids[*]
  public_subnet_ids = data.terraform_remote_state.vpc.outputs.public_subnet_ids
  private_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  eks_node_launchtemplate_name     = var.eks_node_launchtemplate_name
  default_node_group_name          = var.default_node_group_name
  default_node_group_instance_type = var.default_node_group_instance_type
  default_node_disk_size           = var.default_node_disk_size
  eks_desired_size_default_node    = var.eks_desired_size_default_node
  eks_max_size_default_node        = var.eks_max_size_default_node
  eks_min_size_default_node        = var.eks_min_size_default_node

  custom_node_group_name = var.custom_node_group_name
  custom_node_group_instance_type = var.custom_node_group_instance_type
  custom_node_disk_size = var.custom_node_disk_size
  eks_desired_size_custom_node = var.eks_desired_size_custom_node
  eks_min_size_custom_node = var.eks_min_size_custom_node
  eks_max_size_custom_node = var.eks_max_size_custom_node

  ebs_rootvol_size = var.ebs_rootvol_size
  ebs_vol_type = var.ebs_vol_type

  eksclustersg_ingress_rules = var.eksclustersg_ingress_rules
  eksworkernodesg_ingress_rules = var.eksworkernodesg_ingress_rules
  
  ekslbcontroller_iamrolename = var.ekslbcontroller_iamrolename
  ekslbcontroller_iampolicyname = var.ekslbcontroller_iampolicyname
  eksclusterautoscaler_iampolicyname = var.eksclusterautoscaler_iampolicyname

  depends_on = [
    data.terraform_remote_state.vpc
  ]
}
