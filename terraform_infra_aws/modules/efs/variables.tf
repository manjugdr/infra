#common
variable "environment" {
  description = "Environment -Dev/QA/Stage/Prod"
}
variable "project_name" {
  description = "ProjectName" 
}
variable "aws_region" {
  description = "AWS region"
}

#VPC
variable "vpc_id" {
  description = "VPC id"
}
variable "private_subnet_ids_for_efs" {
    type = list(string)
}
variable "private_subnet_az_for_efs" {
    type = list(string)
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