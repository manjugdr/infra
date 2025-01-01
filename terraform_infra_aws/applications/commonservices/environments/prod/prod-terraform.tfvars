#common
aws_region = "ap-south-1"
environment = "prod"
project_name = "commonservicesv1-0"


#remote provisioner
argocd_application_helmrepo = "https://github.com/Ascent-Infra/Powerpay-HelmCharts.git"
argocd_application_helmvalues_filename = "values-prod.yaml"
argocd_application_helmservicename-with-path = ["secrets:helm-deployment/powerpay2.1/secretsmanagerchart","nginxlog:helm-deployment/powerpay2.1/commonservicesnginxingresslogschart","keycloak:helm-deployment/powerpay2.1/keycloakchart"] #  "keycloak:helm-deployment/powerpay2.1/keycloakchart" test

#ec2
instanceType = "t2.micro" 
keypairname = "aws-manju" 
associate_public_ip_address = true
bastionhost_iamrole_name = "commonservicesv1-0-bastionhost-administratorrole"
bastionhost_iaminstanceprofile_name = "commonservicesv1-0-bastionhost-instanceprofile"
bastionsg_ingress_rules = {
  ssh_from_all = { from = 22, to = 22, proto = "tcp", cidr = "0.0.0.0/0", desc = "Allow ssh from All" }
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
vpc_cidr_block = "10.35.0.0/16"
public_subnet_cidr_blocks = ["10.35.1.0/24","10.35.2.0/24"]
private_subnet_cidr_blocks = ["10.35.3.0/24","10.35.4.0/24"]
availability_zones = ["ap-south-1a","ap-south-1b"]
public_subnet_additionaltags = {
  "kubernetes.io/role/elb" = "1",
  "kubernetes.io/cluster/commonservicesv1-0-prod-eks" = "shared",
  "kubernetes.io/cluster/stohrmv1-0-prod-eks" = "shared",
  "kubernetes.io/cluster/powerpayv2-1-prod-eks" = "shared"
}
private_subnet_additionaltags = {
  "kubernetes.io/role/internal-elb" = "1",
  "kubernetes.io/cluster/commonservicesv1-0-prod-eks" = "shared",
  "kubernetes.io/cluster/stohrmv1-0-prod-eks" = "shared",
  "kubernetes.io/cluster/powerpayv2-1-prod-eks" = "shared"
}


###################EKS#########################
#eks-cluster
eks_cluster_namespace = "prod"
eks_cluster_name = "commonservicesv1-0-prod-eks"
eks_cluster_version = "1.29"
vpcconfig_endpoint_privateaccess = "true"
vpcconfig_endpoint_publicaccess = "false"

#eks-iam
eks_cluster_rolename = "commonservicesv1-0-prod-eksclusterrole"
eks_node_rolename = "commonservicesv1-0-prod-eksnoderole"

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
eks_node_launchtemplate_name = "commonservicesv1-0-prod-launchtemplate"

#eks-nodegroup
default_node_group_name          = "commonservicesv1-0-prod-defaultnodegroup"
default_node_group_instance_type = ["t3a.large"]
default_node_disk_size           = 20
eks_desired_size_default_node    = 1
eks_max_size_default_node        = 4
eks_min_size_default_node        = 1

#eks-custom nodegroup
custom_node_group_name = ["commonservicesv1-0-prod-customnodegroups"]
custom_node_group_instance_type = ["t2.micro"]
custom_node_disk_size = [40]
eks_desired_size_custom_node = [1]
eks_min_size_custom_node = [1]
eks_max_size_custom_node = [8]

#eks-loadbalancer controller
ekslbcontroller_iamrolename = "commonservicesv1-0AmazonEKSLoadBalancerControllerRole"
ekslbcontroller_iampolicyname = "commonservicesv1-0AWSLoadBalancerControllerIAMPolicy"
ekslbcontroller_serviceaccountname = "commonservicesv1-0-aws-load-balancer-controller-sa"

#eks-clusterautoscaler
eksclusterautoscaler_iampolicyname = "commonservicesv1-0AWSClusterAutoscalerIAMPolicy"

#ECR
repository_names=["commonservicesv1_0_prod_iam_service"]

#EFS
efssg_ingress_rules = {
  NFS_access = { from = 2049, to = 2049, proto = "tcp", cidr = "10.35.0.0/16", desc = "Allow NFS access to VPC CIDR"},
}
encrypted = true
performance_mode = "generalPurpose"
throughput_mode = "provisioned"
backup_policy_status = "ENABLED"
provisioned_throughput_in_mibps = 200
lifecycle_management_transition_to_ia = "AFTER_7_DAYS"
