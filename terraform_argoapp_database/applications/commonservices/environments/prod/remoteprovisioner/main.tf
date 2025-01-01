module "remoteprovisioner" {
  source = "../../../../../modules/remoteprovisioner"
  aws_region = var.aws_region
  project_name = var.project_name
  # Referencing VPC output from remote state
  eks_cluster_name = var.eks_cluster_name
  bastionhost_publicip = data.terraform_remote_state.ec2.outputs.bastionhost_publicip
  argocd_clustername = data.terraform_remote_state.eks.outputs.clustername
  eks_cluster_arn = data.terraform_remote_state.eks.outputs.cluster-arn
  eks_cluster_namespace = var.eks_cluster_namespace
  github_username = var.github_username
  github_password = var.github_password
  argocd_application_helmrepo = var.argocd_application_helmrepo
  argocd_application_helmvalues_filename = var.argocd_application_helmvalues_filename
  argocd_application_helmservicename-with-path = var.argocd_application_helmservicename-with-path
  depends_on = [
    data.terraform_remote_state.eks,
    data.terraform_remote_state.ec2
  ]
}

data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "ascent-terraform-statefile"
    key    = "commonservices/prod/eks/terraform.tfstate"
    region = "ap-south-1"
  }
}
data "terraform_remote_state" "ec2" {
  backend = "s3"
  config = {
    bucket = "ascent-terraform-statefile"
    key    = "commonservices/prod/ec2/terraform.tfstate"
    region = "ap-south-1"
  }
}

