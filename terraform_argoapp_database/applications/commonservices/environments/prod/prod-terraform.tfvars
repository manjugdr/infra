#common
aws_region = "ap-south-1"
environment = "prod"
project_name = "commonservicesv1-0"

#remote provisioner
argocd_application_helmrepo = "https://github.com/Ascent-Infra/Commonservices-HelmCharts.git"
argocd_application_helmvalues_filename = "values-prod.yaml"
#argocd_application_helmservicename-with-path = ["secrets:helm-deployment/commonservices1.0/secretsmanagerchart","nginxlog:helm-deployment/commonservices1.0/commonservicesnginxingresslogschart","keycloak:helm-deployment/commonservices1.0/keycloakchart"] #  "keycloak:helm-deployment/powerpay2.1/keycloakchart" test

#ec2
keypairname = "bastionhost-key" 


###################EKS#########################
#eks-cluster
eks_cluster_namespace = "prod"
eks_cluster_name = "commonservicesv1-0-prod-eks"
eks_cluster_version = "1.29"
vpcconfig_endpoint_privateaccess = "true"
vpcconfig_endpoint_publicaccess = "false"





