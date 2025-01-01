#common
aws_region = "ap-south-1"
bucket_name = "stohrm-terraform-tfstate"
environment = "qa"
project_name = "stohrmv2-0"


#remote provisioner
argocd_application_helmrepo = "https://github.com/Ascent-Infra/Stohrm-HelmCharts.git"
argocd_application_helmpath = "helm-deployment/stohrmchart"
argocd_application_helmvalues_filename = "values-qa.yaml"

#ec2
instanceType = "t2.micro" 
keypairname = "bastionhost-key" 
associate_public_ip_address = true
bastionhost_iamrole_name = "stohrm-bastionhost-administratorrole"
bastionhost_iaminstanceprofile_name = "stohrm-bastionhost-instanceprofile"
bastionsg_ingress_rules = {
  ssh_from_all = { from = 22, to = 22, proto = "tcp", cidr = "0.0.0.0/0", desc = "Allow ssh from All" }
 // rev_pritunl_Ui = { from = 443, to = 443, proto = "tcp", cidr = "0.0.0.0/0", desc = "Allow ssh from Pritunl" }  
}

#ebsvolumes- ec2/eks
ebs_rootvol_size = {
  "bastion" = "30"
  "eks-defaultnodegroup" = "20"
}
ebs_vol_type = {
  "default" = "gp3"
}




#vpcs
vpc_cidr_block = "10.30.0.0/16"
public_subnet_cidr_blocks = ["10.30.1.0/24","10.30.2.0/24"]
private_subnet_cidr_blocks = ["10.30.3.0/24","10.30.4.0/24"]
availability_zones = ["ap-south-1a","ap-south-1b"]


###################EKS#########################
#eks-cluster
eks_cluster_namespace = "qa"
eks_cluster_name = "stohrmv2-0-qa-eks"
eks_cluster_version = "1.29"
vpcconfig_endpoint_privateaccess = "true"
vpcconfig_endpoint_publicaccess = "false"

#eks-iam
eks_cluster_rolename = "stohrmv2-0-qa-eksclusterrole"
eks_node_rolename = "stohrmv2-0-qa-eksnoderole"

#eks-sg
eksclustersg_ingress_rules = {
  https_access = { from = 443, to = 443, proto = "tcp", cidr = "0.0.0.0/0", desc = "Allow access to kube"},
  http_access = { from = 80, to = 80, proto = "tcp", cidr = "0.0.0.0/0", desc = "Allow access to kube" } 
}
#eks-launch template
eks_node_launchtemplate_name = "storhmv2-0-qa-launchtemplate"
#eks-nodegroup
default_node_group_name          = "storhmv2-0-qa-defaultnodegroup"
default_node_group_instance_type = ["t3a.large"]
default_node_disk_size           = 20
eks_desired_size_default_node    = 1
eks_max_size_default_node        = 4
eks_min_size_default_node        = 1

#eks-custom nodegroup
custom_node_group_name = ["storhmv2-0-qa-customnodegroup"]
custom_node_group_instance_type = ["t3a.large"]
custom_node_disk_size = [40]
eks_desired_size_custom_node = [1]
eks_min_size_custom_node = [1]
eks_max_size_custom_node = [4]

#eks-loadbalancer controller
ekslbcontroller_iamrolename = "stohrmv2-0AmazonEKSLoadBalancerControllerRole"
ekslbcontroller_iampolicyname = "stohrmv2-0AWSLoadBalancerControllerIAMPolicy"
ekslbcontroller_serviceaccountname = "storhmv2-0-aws-load-balancer-controller-sa"

#eks-clusterautoscaler
eksclusterautoscaler_iampolicyname = "stohrmv2-0AWSClusterAutoscalerIAMPolicy"

################RDS#####################################
rds_subnetgroup_name = "storhmv2-0-qa-rdsdbsubnetgroup"
rds_db_count = 1
rdssg_ingress_rules = {
  allow_within_vpc = { from = 3306, to = 3306, proto = "tcp", cidr = "0.0.0.0/0", desc = "Allow MariaDB from All" }
}
rds_db_allocated_storage = [200]
rds_db_engine = ["mariadb"]
rds_db_engine_version = ["10.6.14"]
rds_db_instancetype = ["db.t3.large"]
rds_db_identifier = ["storhmv2-0-qa-rds"]
rds_db_storagetype = ["gp3"] 
rds_db_username = ["xyZZySp"]
rds_db_password = ["Q1EisMAUcWU5qY!U"]
rds_db_is_skipfinalsnapshot = [true]
rds_db_is_publicaccess = [false]
rds_db_max_allocated_storage = [200]
rds_db_is_performance_insights_enabled = [true]
rds_db_performance_insights_retention_period = [7]

rds_db_backup_retention_period = [30]
rds_db_backup_window = ["10:00-12:00"]
rds_db_storage_encrypted = [true]
rds_db_copy_tags_to_snapshot = [true]
rds_db_enable_multi_az = [false]
rds_db_deletion_protection = [false]
rds_db_enabled_cloudwatch_logs_exports = ["error", "general", "audit"] 

#ECR

repository_names=["stohrmv2-0_qa_app"]
