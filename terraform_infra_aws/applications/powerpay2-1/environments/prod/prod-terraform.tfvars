#common
aws_region = "ap-south-1"
environment = "prod"
project_name = "powerpayv2-1"

#remote provisioner
argocd_application_helmrepo = "https://github.com/Ascent-Infra/Powerpay-HelmCharts.git"
argocd_application_helmvalues_filename = "values-prod.yaml"
argocd_application_helmservicename-with-path = ["secrets:helm-deployment/powerpay2.1/secretsmanagerchart","nginxlog:helm-deployment/powerpay2.1/ppnginxingresslogschart","rabbitmq:helm-deployment/powerpay2.1/rabbitmqchart","cm:helm-deployment/powerpay2.1/configmanagerchart","ge:helm-deployment/powerpay2.1/generalizationservicechart","iam:helm-deployment/powerpay2.1/iamservicechart","pe:helm-deployment/powerpay2.1/payrollenginechart","report-gen:helm-deployment/powerpay2.1/reportgenerationservicechart","report-process:helm-deployment/powerpay2.1/reportprocessingservicechart","24q-process:helm-deployment/powerpay2.1/24qprocessingservicechart","org:helm-deployment/powerpay2.1/organizationservicechart","ui:helm-deployment/powerpay2.1/powerpayuichart"]

#ec2
instanceType = "t3.medium" 
keypairname = "bastionhost-key" 
associate_public_ip_address = false
//ec2mongo_iamrole_name = "stohrm-bastionhost-administratorrole"
//ec2mongo_iaminstanceprofile_name = "stohrm-bastionhost-instanceprofile"
ec2mongosg_ingress_rules = {
  mongodb_port = { from = 27017, to = 27017, proto = "tcp", cidr = "10.35.0.0/16", desc = "Allow mongodb port within vpc" }  
  //ssh rule added within script
}

#ebsvolumes- ec2/eks
ebs_rootvol_size = {
  "bastion" = "30"
  "eks-defaultnodegroup" = "20"
  "ec2mongo" = "30"
}
ebs_vol_type = {
  "default" = "gp3"
}




#vpcs
vpc_cidr_block = "10.35.0.0/16"
public_subnet_cidr_blocks = ["10.35.1.0/24","10.35.2.0/24"]
private_subnet_cidr_blocks = ["10.35.3.0/24","10.35.4.0/24"]
availability_zones = ["ap-south-1a","ap-south-1b"]


###################EKS#########################
#eks-cluster
eks_cluster_namespace = "prod"
eks_cluster_name = "powerpayv2-1-prod-eks"
eks_cluster_version = "1.29"
vpcconfig_endpoint_privateaccess = "true"
vpcconfig_endpoint_publicaccess = "false"

#eks-iam
eks_cluster_rolename = "powerpayv2-1-prod-eksclusterrole"
eks_node_rolename = "powerpayv2-1-prod-eksnoderole"

#eks-sg
eksclustersg_ingress_rules = {
  https_access = { from = 443, to = 443, proto = "tcp", cidr = "0.0.0.0/0", desc = "Allow access to kube"},
  http_access = { from = 80, to = 80, proto = "tcp", cidr = "0.0.0.0/0", desc = "Allow access to kube" }
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
eks_node_launchtemplate_name = "powerpayv2-1-prod-launchtemplate"
#eks-nodegroup
default_node_group_name          = "powerpayv2-1-prod-defaultnodegroup"
default_node_group_instance_type = ["t3a.large"]
default_node_disk_size           = 20
eks_desired_size_default_node    = 1
eks_max_size_default_node        = 4
eks_min_size_default_node        = 1

#eks-custom nodegroup
custom_node_group_name = ["powerpayv2-1-prod-customnodegroups"]
custom_node_group_instance_type = ["m5.2xlarge"]
custom_node_disk_size = [40]
eks_desired_size_custom_node = [1]
eks_min_size_custom_node = [1]
eks_max_size_custom_node = [8]

#eks-loadbalancer controller
ekslbcontroller_iamrolename = "powerpayv2-1AmazonEKSLoadBalancerControllerRole"
ekslbcontroller_iampolicyname = "powerpayv2-1AWSLoadBalancerControllerIAMPolicy"
ekslbcontroller_serviceaccountname = "powerpayv2-1-aws-load-balancer-controller-sa"

#eks-clusterautoscaler
eksclusterautoscaler_iampolicyname = "powerpayv2-1AWSClusterAutoscalerIAMPolicy"

################RDS#####################################
rds_subnetgroup_name = "powerpayv2-1-prod-rdsdbsubnetgroup"
rds_db_count = 3
rdssg_ingress_rules = {
  allow_within_vpc = { from = 5432, to = 5432, proto = "tcp", cidr = "0.0.0.0/0", desc = "Allow postgressql from All" }
}
rds_db_allocated_storage = [50,50,50]
rds_db_engine = ["postgres","postgres","postgres"]
rds_db_engine_version = ["14.12","14.12","14.12"]
rds_db_instancetype = ["db.t3.large","db.t3.large","db.t3.large"]
rds_db_identifier = ["powerpayv2-1-prod-ge-rds","powerpayv2-1-prod-reports-rds","powerpayv2-1-prod-pe-rds"]
rds_db_storagetype = ["gp3","gp3","gp3"] 
#rds_db_username = ["postgres","postgres","postgres"]
#rds_db_password = ["Powerpay123","Powerpay123","Powerpay123"]
rds_db_is_skipfinalsnapshot = [true,true,true]
rds_db_is_publicaccess = [false,false,false]
rds_db_max_allocated_storage = [100,100,100]
rds_db_is_performance_insights_enabled = [true,true,true]
rds_db_performance_insights_retention_period = [7,7,7]

rds_db_backup_retention_period = [7,7,7]
rds_db_backup_window = ["07:00-09:00","07:00-09:00","07:00-09:00"]
rds_db_storage_encrypted = [true,true,true]
rds_db_copy_tags_to_snapshot = [true,true,true]
rds_db_enable_multi_az = [false,false,false]
rds_db_deletion_protection = [false,false,false]
rds_db_enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"] 


#ECR

repository_names=["ppv2_1_prod_config_manager",
"ppv2_1_prod_24qprocessing_service",
"ppv2_1_prod_generalization_service",
"ppv2_1_prod_iam_service",
"ppv2_1_prod_organization_service",
"ppv2_1_prod_payroll_engine",
"ppv2_1_prod_powerpayui",
"ppv2_1_prod_reportgeneration_service",
"ppv2_1_prod_reportprocessing_service"
]