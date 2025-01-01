variable "environment" {
  description = "Environment -Dev/QA/Stage/Prod"
}
variable "project_name" {
  description = "ProjectName" 
}
variable "aws_region" {
  description = "AWS region"
}
variable "instanceType" {
  description = "Name for the VPC"
}
variable "keypairname" {
  description = "Name of keypair"
}
variable "associate_public_ip_address" {
  description = "Boolean Value of whether to allocate public IP to BastionHost"
}
variable "vpc_id" {
  description = "public subnet ID"
}
//variable "public_subnet_ids" {
//  description = "public subnet ID"
//}
variable "private_subnet_ids" {
  description = "private subnet ID"
}
variable "ec2mongosg_ingress_rules" {
  type = map
}
variable "ebs_rootvol_size" {
  type = map
}
variable "ebs_vol_type" {
  type = map
}
//variable "ec2mongo_iamrole_name" {
//  description = "BastionHost Admin Role name"
//}
//variable "ec2mongo_iaminstanceprofile_name" {
//  description = "BastionHost Instance Profile"
//}
variable "bastionhost_privateip" {
  description = "To allow ssh access only to bastionhost"
}
#===========================================

/*variable "aws_access_key_id"{

}
variable "aws_secret_access_key"{

}

variable "eks_cluster_name" {
    type = string
}
#EKS-aws load balancer controller

variable "ekslbcontroller_iamrolename" {
    type = string
}
variable "ekslbcontroller_serviceaccountname" {
    type = string
}
variable "ekslbcontroller_iampolicyarn" {
  //retrieved from eks module
}*/
