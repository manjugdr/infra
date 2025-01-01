#common
aws_region = "ap-south-1"
bucket_name = "stohrm-terraform-tfstate"
environment = "prod"
project_name = "stohrmv1-0"
github_username = "preethi-ascenthr"


#remote provisioner
argocd_application_helmrepo = "https://github.com/Ascent-Infra/Stohrm-HelmCharts.git"
argocd_application_helmservicename-with-path = ["helm-deployment/stohrm1.0/stohrmchart"]
argocd_application_helmvalues_filename = "values-prod.yaml"

#ec2
instanceType = "t2.micro" 
keypairname = "bastionhost-key" 
associate_public_ip_address = true
#bastionhost_iamrole_name = "stohrm-bastionhost-administratorrole"
#bastionhost_iaminstanceprofile_name = "stohrm-bastionhost-instanceprofile"
#bastionsg_ingress_rules = {
#  ssh_from_all = { from = 22, to = 22, proto = "tcp", cidr = "0.0.0.0/0", desc = "Allow ssh from All" }
 // rev_pritunl_Ui = { from = 443, to = 443, proto = "tcp", cidr = "0.0.0.0/0", desc = "Allow ssh from Pritunl" }  
#

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
eks_cluster_namespace = "prod"
eks_cluster_name = "stohrmv1-0-prod-eks"
eks_cluster_version = "1.29"
vpcconfig_endpoint_privateaccess = "true"
vpcconfig_endpoint_publicaccess = "false"

#eks-iam
eks_cluster_rolename = "stohrmv1-0-prod-eksclusterrole"
eks_node_rolename = "stohrmv1-0-prod-eksnoderole"

#eks-sg
eksclustersg_ingress_rules = {
  https_access = { from = 443, to = 443, proto = "tcp", cidr = "10.35.0.0/16", desc = "Allow access to kube"},
  http_access = { from = 80, to = 80, proto = "tcp", cidr = "10.35.0.0/16", desc = "Allow access to kube" } 
}
eksworkernodesg_ingress_rules = {
  https_access = { from = 443, to = 443, proto = "tcp", cidr = "10.35.0.0/16", desc = "Allow access to kube"},
  http_access = { from = 80, to = 80, proto = "tcp", cidr = "10.35.0.0/16", desc = "Allow access to kube" },
  alb_nginx_access = { from  = 9443, to = 9443, proto = "tcp", cidr  = "10.35.0.0/16", desc  = "Allow access btwn nginx and alb controller"},
  dns_tcp = { from  = 53, to = 53, proto = "tcp", cidr  = "10.35.0.0/16", desc  = "Allow DNS TCP port to resolve cluster svc dns"},
  dns_udp = { from  = 53, to = 53, proto = "udp", cidr  = "10.35.0.0/16", desc  = "Allow DNS UDP port to resolve cluster svc dns"},
  argocd_repo_server = { from  = 8081, to = 8081, proto = "tcp", cidr  = "10.35.0.0/16", desc  = "Allow access btwn argocd and secretmnager to communicate"},
  argocd_repo_servers = { from  = 8084, to = 8084, proto = "tcp", cidr  = "10.35.0.0/16", desc  = "Allow access btwn argocd and secretmnager to communicate"},
  aws_secret_manager = { from  = 10250, to = 10250, proto = "tcp", cidr  = "10.35.0.0/16", desc  = "Allow access btwn eks worker node and secretmanager"}
}
#eks-launch template
eks_node_launchtemplate_name = "stohrmv1-0-prod-launchtemplate"
#eks-nodegroup
default_node_group_name          = "stohrmv1-0-prod-defaultnodegroup"
default_node_group_instance_type = ["t3a.large"]
default_node_disk_size           = 20
eks_desired_size_default_node    = 1
eks_max_size_default_node        = 4
eks_min_size_default_node        = 1

#eks-custom nodegroup
custom_node_group_name = ["stohrmv1-0-prod-customnodegroup"]
custom_node_group_instance_type = ["t3a.large"]
custom_node_disk_size = [40]
eks_desired_size_custom_node = [1]
eks_min_size_custom_node = [1]
eks_max_size_custom_node = [4]

#eks-loadbalancer controller
ekslbcontroller_iamrolename = "stohrmv1-0AmazonEKSLoadBalancerControllerRole"
ekslbcontroller_iampolicyname = "stohrmv1-0AWSLoadBalancerControllerIAMPolicy"
ekslbcontroller_serviceaccountname = "stohrmv1-0-aws-load-balancer-controller-sa"

#eks-clusterautoscaler
eksclusterautoscaler_iampolicyname = "stohrmv1-0AWSClusterAutoscalerIAMPolicy"

################RDS#####################################
rds_subnetgroup_name = "stohrmv1-0-prod-rdsdbsubnetgroup"
rds_db_count = 1
rdssg_ingress_rules = {
  allow_within_vpc = { from = 3306, to = 3306, proto = "tcp", cidr = "0.0.0.0/0", desc = "Allow MariaDB from All" }
}
rds_db_allocated_storage = [200]
rds_db_engine = ["mariadb"]
rds_db_engine_version = ["10.6.14"]
rds_db_instancetype = ["db.t3.large"]
rds_db_identifier = ["stohrmv1-0-prod-rds"]
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

repository_names=["stohrmv1-0_prod_app"]

#Elasticcache redis

  replication_group_id = "stohrmv1-0-prod-rediscache"
  replication_group_description = "Elasticcache redis for stohrmv1-0"
  replication_group_engine                        = "redis"
  replication_group_engine_version                = "7.1"
  replication_group_node_type                     = "cache.r7g.large"
  replication_group_num_cache_clusters            = 2  # For cluster mode enabled with 1 replica
  replication_group_multi_az_enabled              = true
  replication_group_automatic_failover_enabled    = true
  replication_group_port                          = 6379
  replication_group_snapshot_retention_limit      = 7  # Automatic backups enabled
  replication_group_snapshot_window               = "00:00-01:00"  # No preference on window
  replication_group_at_rest_encryption_enabled    = true
  replication_group_transit_encryption_enabled    = false
  replication_group_apply_immediately = true
  replication_group_maintenance_window = "sat:01:01-sat:02:01"  # Maintenance window
  replication_group_log_type_engine_log = "engine-log"
  replication_group_log_type_slow_log = "slow-log"
  replication_group_log_destination_type = "cloudwatch-logs"
  replication_group_log_format = "json"

  elasticcache_subnet_group_name = "stohrmv1-0-prod-rediscachesubnetgroup"
  elasticcache_subnet_group_description = "Elasticcache redis subnetgroup for stohrmv1-0"

  elasticcache_param_group_name = "stohrmv1-0-prod-rediscacheparamgroup"
  elasticcache_param_group_family      = "redis7"
  elasticcache_param_group_description = "Parameter group for ElastiCache Redis 7.1"

  elasticcache_cwlog_group_name = "stohrm-prod-rediscachelogs"
  elasticcache_cwlog_group_retentiondays = 7

  elasticcache_sg_ingress_rules = {
  allow_within_vpc = { from = 6379, to = 6379, proto = "tcp", cidr = "10.35.0.0/16", desc = "Allow within VPC" }
}