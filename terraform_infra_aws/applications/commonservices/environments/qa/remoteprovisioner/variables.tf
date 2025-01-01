
# Common
variable "aws_region" {
  description = "AWS region"
}
variable "environment" {
  description = "Environment -qa/QA/Stage/Prod"
  default = "qa"
}
variable "project_name" {
  description = "ProjectName" 
  default = "commonservices"
}

variable "aws_access_key_id"{
}
variable "aws_secret_access_key"{
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
#EKS-aws load balancer controller

variable "ekslbcontroller_iamrolename" {
    type = string
}
variable "ekslbcontroller_serviceaccountname" {
  type = string
}

