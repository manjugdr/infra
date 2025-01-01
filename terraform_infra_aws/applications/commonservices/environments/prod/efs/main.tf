module "efs" {
  source = "../../../../../modules/efs"
  environment = var.environment
  project_name = var.project_name
  aws_region = var.aws_region
  # Referencing VPC output from remote state
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  private_subnet_ids_for_efs = data.terraform_remote_state.vpc.outputs.private_subnet_ids[*]
  private_subnet_az_for_efs = data.terraform_remote_state.vpc.outputs.private_subnet_availabilityzones[*]
  efssg_ingress_rules = var.efssg_ingress_rules
  encrypted = var.encrypted
  performance_mode = var.performance_mode
  throughput_mode = var.throughput_mode
  backup_policy_status = var.backup_policy_status
  provisioned_throughput_in_mibps = var.provisioned_throughput_in_mibps
  lifecycle_management_transition_to_ia = var.lifecycle_management_transition_to_ia
  depends_on = [
    data.terraform_remote_state.vpc
  ]
}

# Data source to retrieve the remote state of the VPC
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "ascent-terraform-statefile"
    key    = "commonservices/prod/vpc/terraform.tfstate"
    region = "ap-south-1"
  }
}
