#common
aws_region = "ap-south-1"
environment = "dev"
project_name = "commonservicesv1-0"

#remote provisioner
argocd_application_helmrepo = "https://github.com/Ascent-Infra/Powerpay-HelmCharts.git"
argocd_application_helmvalues_filename = "values-dev.yaml"
argocd_application_helmservicename-with-path = ["secrets:helm-deployment/powerpay2.1/secretsmanagerchart","nginxlog:helm-deployment/powerpay2.1/commonservicesnginxingresslogschart","keycloak:helm-deployment/powerpay2.1/keycloakchart"] #  "keycloak:helm-deployment/powerpay2.1/keycloakchart" test

#ec2
keypairname = "bastionhost-key" 


###################EKS#########################
#eks-cluster
eks_cluster_namespace = "dev"
eks_cluster_name = "commonservicesv1-0-dev-eks"
eks_cluster_version = "1.29"
vpcconfig_endpoint_privateaccess = "true"
vpcconfig_endpoint_publicaccess = "false"





