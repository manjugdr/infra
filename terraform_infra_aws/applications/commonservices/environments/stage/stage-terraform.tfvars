#common
aws_region = "ap-south-1"
environment = "stage"
project_name = "commonservicesv1-0"



#remote provisioner
argocd_application_helmrepo = "https://github.com/Ascent-Infra/Powerpay-HelmCharts.git"
argocd_application_helmvalues_filename = "values-stage.yaml"
argocd_application_helmservicename-with-path = ["secrets:helm-deployment/powerpay2.1/secretsmanagerchart","nginxlog:helm-deployment/powerpay2.1/commonservicesnginxingresslogschart","keycloak:helm-deployment/powerpay2.1/keycloakchart"] #  "keycloak:helm-deployment/powerpay2.1/keycloakchart" test

#ec2
instanceType = "t2.micro" 
keypairname = "bastionhost-key" 
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
vpc_cidr_block = "10.30.0.0/16"
public_subnet_cidr_blocks = ["10.30.1.0/24","10.30.2.0/24"]
private_subnet_cidr_blocks = ["10.30.3.0/24","10.30.4.0/24"]
availability_zones = ["ap-south-1a","ap-south-1b"]
public_subnet_additionaltags = {
  "kubernetes.io/role/elb" = "1",
  "kubernetes.io/cluster/commonservicesv1-0-stage-eks" = "shared",
  "kubernetes.io/cluster/stohrmv2-0-stage-eks" = "shared",
  "kubernetes.io/cluster/powerpayv2-1-stage-eks" = "shared"
}
private_subnet_additionaltags = {
  "kubernetes.io/role/internal-elb" = "1",
  "kubernetes.io/cluster/commonservicesv1-0-stage-eks" = "shared",
  "kubernetes.io/cluster/stohrmv2-0-stage-eks" = "shared",
  "kubernetes.io/cluster/powerpayv2-1-stage-eks" = "shared"
}


###################EKS#########################
#eks-cluster
eks_cluster_namespace = "stage"
eks_cluster_name = "commonservicesv1-0-stage-eks"
eks_cluster_version = "1.29"
vpcconfig_endpoint_privateaccess = "true"
vpcconfig_endpoint_publicaccess = "false"

#eks-iam
eks_cluster_rolename = "commonservicesv1-0-stage-eksclusterrole"
eks_node_rolename = "commonservicesv1-0-stage-eksnoderole"

#eks-sg
eksclustersg_ingress_rules = {
  https_access = { from = 443, to = 443, proto = "tcp", cidr = "0.0.0.0/0", desc = "Allow access to kube"},
  http_access = { from = 80, to = 80, proto = "tcp", cidr = "0.0.0.0/0", desc = "Allow access to kube" } 
}
eksworkernodesg_ingress_rules = {
  https_access = { from = 443, to = 443, proto = "tcp", cidr = "10.30.0.0/16", desc = "Allow access to kube"},
  http_access = { from = 80, to = 80, proto = "tcp", cidr = "10.30.0.0/16", desc = "Allow access to kube" },
}
#eks-launch template
eks_node_launchtemplate_name = "commonservicesv1-0-stage-launchtemplate"

#eks-nodegroup
default_node_group_name          = "commonservicesv1-0-stage-defaultnodegroup"
default_node_group_instance_type = ["t3a.large"]
default_node_disk_size           = 20
eks_desired_size_default_node    = 1
eks_max_size_default_node        = 4
eks_min_size_default_node        = 1

#eks-custom nodegroup
custom_node_group_name = ["commonservicesv1-0-stage-customnodegroups"]
custom_node_group_instance_type = ["m5.2xlarge"]
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
repository_names=["commonservicesv1_0_stage_iam_service"]
