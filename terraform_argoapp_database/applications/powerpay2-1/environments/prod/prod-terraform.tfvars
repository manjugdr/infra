#common
aws_region = "ap-south-1"
environment = "prod"
project_name = "powerpayv2-1"

#remote provisioner
argocd_application_helmrepo = "https://github.com/Ascent-Infra/Powerpay-HelmCharts.git"
argocd_application_helmvalues_filename = "values-prod.yaml"
#argocd_application_helmservicename-with-path = ["secrets:helm-deployment/commonservices1.0/secretsmanagerchart","nginxlog:helm-deployment/commonservices1.0/commonservicesnginxingresslogschart","keycloak:helm-deployment/commonservices1.0/keycloakchart"] #  "keycloak:helm-deployment/powerpay2.1/keycloakchart" test

#ec2
keypairname = "bastionhost-key" 


###################EKS#########################
#eks-cluster
eks_cluster_namespace = "prod"
eks_cluster_name = "powerpayv2-1-prod-eks"
eks_cluster_version = "1.29"
vpcconfig_endpoint_privateaccess = "true"
vpcconfig_endpoint_publicaccess = "false"





