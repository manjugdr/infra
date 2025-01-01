
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

#remote provisioner
variable "argocd_application_helmrepo"{
}
variable "argocd_application_helmpath"{
}
variable "argocd_application_helmvalues_filename"{
}
#ec2
variable "instanceType" {
  description = "Name for the VPC"
}
variable "keypairname" {
  description = "Name for the VPC"
}
variable "associate_public_ip_address" {
  description = "Boolean Value of whether to allocate public IP to BastionHost"
}
variable "bastionsg_ingress_rules" {
  type = map
}
variable "bastionhost_iamrole_name" {
  description = "BastionHost Admin Role name"
}
variable "bastionhost_iaminstanceprofile_name" {
  description = "BastionHost Instance Profile"
}

/*variable "bastionhost_rolearn" {
  description = "EKS Node role ARN - To be attached as BastionHost Role"
}
variable "bastionhost_roleinstanceprofilearn" {
  description = "EKS Node role Instanceprofile name - To be attached as BastionHost Role"
}*/
#ebs volumes- ec2/eks
variable "ebs_rootvol_size" {
  type = map
}
variable "ebs_vol_type" {
  type = map
}
//variable "public_subnet_ids" {
//  description = "public subnet ID"
//}

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


#############RDS################
variable "rds_db_count" {
  description = "No.of RDS instances to be created"
}
variable "rds_subnetgroup_name" {
  description = "rds_subnetgroup_name"
}
variable "rds_db_allocated_storage" {
  description = "allocated_storage"
}
variable "rds_db_engine" {
  description = "rds db engine-mysql/postgresql/mariadb/mssql"
}
variable "rds_db_engine_version" {
  description = "rds db engine version of -mysql/postgresql/mariadb/mssql"
}
variable "rds_db_instancetype" {
  description = "rds db instance type"
}
variable "rds_db_identifier" {
  description = "rds db name"
}
variable "rds_db_storagetype" {
  description = "rds db name"
}
variable "rds_db_username" {
  description = "rds db username"
}
variable "rds_db_password" {
  description = "rds db password"
}
variable "rds_db_is_skipfinalsnapshot" {
  description = "skipfinalsnapshot - true/false"
}
variable "rds_db_is_publicaccess" {
  description = "To enable public access - true/false"
}
variable "rds_db_max_allocated_storage" {
    description = "Max storage value"
}
variable "rds_db_is_performance_insights_enabled" {
    description = "performance_insights_enabled - true/false"
}
variable "rds_db_performance_insights_retention_period" {
    description = "performance_insights_retention_period"
}
variable "rdssg_ingress_rules" {
    type = map
}
#RDS Additional settings

variable "rds_db_backup_retention_period" {
    description = "retention days"
}
variable "rds_db_backup_window" {
    description = "date for backup window"
}
variable "rds_db_storage_encrypted" {
    description = "encryption- true/false"
}
variable "rds_db_copy_tags_to_snapshot" {
    description = "copy snapshots- true/false"
} 
variable "rds_db_enable_multi_az" {
    description = "Enable multi-AZ- true/false"
} 
variable "rds_db_deletion_protection" {
    description = "Deletion Protection- true/false"
}
variable "rds_db_enabled_cloudwatch_logs_exports" {
    description = "Enabled logs postgresql/upgrade"
} 



#ECR

# Define a list of repository names
variable "repository_names" {
  type    = list(string)
}