# Common
variable "aws_region" {
  description = "AWS region"
}
variable "environment" {
  description = "Environment -Dev/QA/prod/Prod"
  default = "prod"
}
variable "project_name" {
  description = "ProjectName" 
  default = "commonservices"
}


#EFS

variable "efssg_ingress_rules" {
  description = "EFS ingress rules"
}

variable "encrypted" {
}
variable "performance_mode" {
}
variable "throughput_mode" {
}
variable "backup_policy_status" {
}
variable "provisioned_throughput_in_mibps" {
}
variable "lifecycle_management_transition_to_ia" {
}

