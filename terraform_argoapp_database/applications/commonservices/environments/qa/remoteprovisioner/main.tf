module "remoteprovisioner" {
  source = "../../../../../modules/remoteprovisioner"
  aws_region = var.aws_region
  project_name = var.project_name
  # Referencing VPC output from remote state
  aws_access_key_id = var.aws_access_key_id
  aws_secret_access_key = var.aws_secret_access_key
  eks_cluster_name = var.eks_cluster_name
  ekslbcontroller_iamrolename = var.ekslbcontroller_iamrolename
  ekslbcontroller_serviceaccountname = var.ekslbcontroller_serviceaccountname
  ekslbcontroller_iampolicyarn = data.terraform_remote_state.eks.outputs.ekslbcontroller_iampolicyarn
  bastionhost_publicip = data.terraform_remote_state.ec2.outputs.bastionhost_publicip
  argocd_clustername = data.terraform_remote_state.eks.outputs.clustername
  eks_applicationcluster_url = data.terraform_remote_state.eks.outputs.eks_cluster_serverurl
  eks_cluster_arn = data.terraform_remote_state.eks.outputs.cluster-arn
  eks_cluster_namespace = var.eks_cluster_namespace
  github_username = var.github_username
  github_password = var.github_password
  argocd_application_helmrepo = var.argocd_application_helmrepo
  argocd_application_helmvalues_filename = var.argocd_application_helmvalues_filename
  argocd_application_helmservicename-with-path = var.argocd_application_helmservicename-with-path
  depends_on = [
    data.terraform_remote_state.vpc,
    data.terraform_remote_state.eks,
    data.terraform_remote_state.ec2
  ]
}

# Data source to retrieve the remote state of the VPC
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "ascent-terraform-statefiles"
    key    = "commonservices/qa/vpc/terraform.tfstate"
    region = "ap-south-1"
  }
}
data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "ascent-terraform-statefiles"
    key    = "commonservices/qa/eks/terraform.tfstate"
    region = "ap-south-1"
  }
}
data "terraform_remote_state" "ec2" {
  backend = "s3"
  config = {
    bucket = "ascent-terraform-statefiles"
    key    = "commonservices/qa/ec2/terraform.tfstate"
    region = "ap-south-1"
  }
}

