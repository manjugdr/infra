
# Common
variable "aws_region" {
  description = "AWS region"
}
variable "bucket_name" {
  description = "BucketName"
  default = "default-tfstate"
}
variable "environment" {
  description = "Environment -Dev/QA/Stage/Prod"
  default = "dev"
}
variable "project_name" {
  description = "ProjectName" 
  default = "powerpay2.0"
}
variable "aws_access_key_id"{

}
variable "aws_secret_access_key"{

}
variable "github_username"{
}
variable "github_password"{
}

#vpc

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  description = "CIDR blocks for public subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidr_blocks" {
  description = "CIDR blocks for private subnets"
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "Availability zones for subnets"
  default     = ["ap-south-1a", "ap-south-1b"]
}


##############eks##########################



#eks-cluster

variable "eks_cluster_name" {
    type = string
}
variable "eks_cluster_version" {
    type = string
}
variable "vpcconfig_endpoint_privateaccess" {
    type = string
}
variable "vpcconfig_endpoint_publicaccess" {
    type = string
}

# EKS-IAM info
variable "eks_cluster_rolename" {
    type = string
}
variable "eks_node_rolename" {
    type = string
}
#EKS - launch template

variable "eks_node_launchtemplate_name" {
    type = string
}
# EKS-default nodes
variable "default_node_group_name" {
    type = string
}
variable "default_node_group_instance_type" {
    type = list(string)
} 
variable "default_node_disk_size" {
    type = number
}
variable "eks_desired_size_default_node" {
    type = number
}
variable "eks_max_size_default_node" {
    type = number
}
variable "eks_min_size_default_node" {
    type = number
}

# EKS - custom nodegroups
variable "custom_node_group_name" {
    type = list(string)
}
variable "custom_node_group_instance_type" {
    type = list(string)
}
variable "custom_node_disk_size" {
    type = list(number)
}
variable "eks_desired_size_custom_node" {
    type = list(number)
}
variable "eks_min_size_custom_node" {
    type = list(number)
}
variable "eks_max_size_custom_node" {
    type = list(number)
}

#EKS-sg
variable "eksclustersg_ingress_rules" {
    type = map
}
variable "eksworkernodesg_ingress_rules" {
    type = map
}
#EKS-aws load balancer controller

variable "ekslbcontroller_iamrolename" {
    type = string
}
variable "ekslbcontroller_iampolicyname" {
    type = string
}
variable "ekslbcontroller_serviceaccountname" {
  type = string
}
variable "eks_cluster_namespace" {
    type = string
}


#EKS - aws cluster autoscaler

variable "eksclusterautoscaler_iampolicyname" {
    type = string
}

