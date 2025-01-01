
# Common
variable "aws_region" {
  description = "AWS region"
}
variable "environment" {
  description = "Environment -Dev/QA/Stage/Prod"
  default = "dev"
}
variable "project_name" {
  description = "ProjectName" 
  default = "commonservices"
}


variable "github_username"{
}
variable "github_password"{
}


#remoteprovisioner
variable "argocd_application_helmrepo"{
}
variable "argocd_application_helmvalues_filename"{
}
variable "argocd_application_helmservicename-with-path"{
  type = list(string)
}  
##############eks##########################



#eks-cluster

variable "eks_cluster_name" {
    type = string
}
variable "eks_cluster_namespace" {
    type = string
}

