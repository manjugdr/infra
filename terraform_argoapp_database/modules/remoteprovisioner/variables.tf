
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


#remote provisioner
variable "argocd_application_helmrepo"{
}
variable "argocd_application_helmvalues_filename"{
}
variable "argocd_application_helmservicename-with-path"{
  type = list(string)
}  #test
##############eks##########################



#eks-cluster
variable "eks_cluster_namespace" {
    type = string
}
variable "eks_cluster_name" {
    type = string
}

variable "eks_cluster_arn" {

}
variable "eks_applicationcluster_url" {
    type = string
}
variable "bastionhost_publicip" {
    type = string
}

variable "argocd_clustername" {
    type = string
}