#!/bin/bash 

# Function to display usage
display_usage() {
    echo "Usage: $0 <AWS_ACCESS_KEY> <AWS_SECRET_KEY> <AWS_REGION> <EKS_CLUSTER_NAME> <EKS_CLUSTER_URL> <EKS_CLUSTER_ARN> <EKS_CLUSTER_NAMESPACE> <EKSLBCONTROLLER_SERVICEACCOUNT_NAME> <EKSLBCONTROLLER_IAMROLE_NAME> <EKSLBCONTROLLER_IAMPOLICY_ARN> <GITHUB_USERNAME> <GITHUB_TOKEN> <ARGOCD_CLUSTER_NAME> <ARGOCD_APPLICATION_HELMREPO> <ARGOCD_APPLICATION_HELMVALUES_FILENAME> <ARGOCD_APPLICATION_NAME> <ARGOCD_APPSVCNAME_HELMPATH>"
    exit 1
}

# Function to set AWS credentials
set_aws_credentials() {
    echo "==============Setting aws credentials===================="
    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY
    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_KEY
    aws configure list
}

# Function to update kubeconfig for EKS cluster
update_kubeconfig() {
    echo "==============Update eks cluster kubeconfig=============="
    aws eks --region $AWS_REGION update-kubeconfig --name $EKS_CLUSTER_NAME
}

# Function to create Kubernetes application namespace
create_namespace() {
    echo "===========kubectl create application namespace==========="
    kubectl create namespace $EKS_CLUSTER_NAMESPACE
}

# Function to install metrics server
install_metrics_server() {
    echo "==============Install metrics server====================="
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
    kubectl get deployment metrics-server -n kube-system
}

# Function to add Helm repo for AWS Load Balancer Controller
add_helm_repo() {
    echo "==========helm repo to add aws Load balancer============="
    helm repo add eks https://aws.github.io/eks-charts
    helm repo update
}

# Function to associate IAM OIDC provider and install AWS Load Balancer Controller
install_aws_load_balancer_controller() {
    echo "==============eksctl commands to install the service account and aws LB=============="
    eksctl utils associate-iam-oidc-provider --region=$AWS_REGION --cluster=$EKS_CLUSTER_NAME --approve
    eksctl create iamserviceaccount --cluster=$EKS_CLUSTER_NAME --namespace=kube-system --name=$EKSLBCONTROLLER_SERVICEACCOUNT_NAME --role-name=$EKSLBCONTROLLER_IAMROLE_NAME --attach-policy-arn=$EKSLBCONTROLLER_IAMPOLICY_ARN --region $AWS_REGION --approve
    helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=$EKS_CLUSTER_NAME --set serviceAccount.create=false --set serviceAccount.name=$EKSLBCONTROLLER_SERVICEACCOUNT_NAME
}

# Function to install nginx ingress controller that hosts all microservices
install_nginx_ingress() {
    echo "==============Install nginx ingress controller==========="
    echo "PATH: $PATH"

    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    ##install_nginx_ingress  
    helm install ingress-nginx ingress-nginx/ingress-nginx \
    --namespace kube-system \
    --set controller.service.type=LoadBalancer \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-name"="powerpayservicesv2-1-prod-nlb" \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-type"="external" \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-scheme"="internet-facing" \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-nlb-target-type"="ip"
}

# Function to deploy cluster autoscaler
deploy_cluster_autoscaler() {
    echo "===============Deploy the cluster autoscaler============="
    sed "s/<CLUSTER_NAME>/$EKS_CLUSTER_NAME/g" files/cluster-autoscaler-autodiscover.yaml | kubectl apply -f -
    kubectl -n kube-system annotate deployment.apps/cluster-autoscaler cluster-autoscaler.kubernetes.io/safe-to-evict="false"
}

# Function to install Prometheus server
install_prometheus() {
    echo "===Install Prometheus server/push Gateway/node exportor==="
    kubectl create namespace monitoring
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    helm upgrade prometheus prometheus-community/prometheus -f files/values-prometheus.yaml -n monitoring
}

# Function to install secretmanager
install_externalsecretoperator() {
  echo "===Install External Secret Oprator to fetch secrets==="
  helm repo add external-secrets https://charts.external-secrets.io
  helm repo update
  helm install external-secrets external-secrets/external-secrets --namespace $EKS_CLUSTER_NAMESPACE
}


main() {
    # Check if all required arguments are provided
    if [ $# -ne 17 ]; then
        echo "Total number of arguments passed: $#"
        display_usage
    fi

    # Array to store arguments
    args=("$@")

    # Assign arguments to variables
    AWS_ACCESS_KEY=${args[0]}
    AWS_SECRET_KEY=${args[1]}
    AWS_REGION=${args[2]}
    EKS_CLUSTER_NAME=${args[3]}
    EKS_CLUSTER_URL=${args[4]}
    EKS_CLUSTER_ARN=${args[5]}
    EKS_CLUSTER_NAMESPACE=${args[6]}
    EKSLBCONTROLLER_SERVICEACCOUNT_NAME=${args[7]}
    EKSLBCONTROLLER_IAMROLE_NAME=${args[8]}
    EKSLBCONTROLLER_IAMPOLICY_ARN=${args[9]}
    GITHUB_USERNAME=${args[10]}
    GITHUB_TOKEN=${args[11]}
    ARGOCD_CLUSTER_NAME=${args[12]}
    ARGOCD_APPLICATION_HELMREPO=${args[13]}
    ARGOCD_APPLICATION_HELMVALUES_FILENAME=${args[14]}
    ARGOCD_APPLICATION_NAME=${args[15]}
    ARGOCD_APPSVCNAME_HELMPATH=${args[16]}
    ARGOCD_SERVER="argocd-prod.stohrm.in"
    ARGOCD_NAMESPACE="argocd"
    ARGOCD_SERVICE_NAME="argocd-server"

    # Display total number of arguments
    echo "Total number of arguments passed: $#"

    # Display all arguments
    echo "AWS_ACCESS_KEY=$AWS_ACCESS_KEY"
    echo "AWS_SECRET_KEY=$AWS_SECRET_KEY"
    echo "AWS_REGION=$AWS_REGION"
    echo "EKS_CLUSTER_NAME=$EKS_CLUSTER_NAME"
    echo "EKS_CLUSTER_URL=$EKS_CLUSTER_URL"
    echo "EKS_CLUSTER_ARN=$EKS_CLUSTER_ARN"
    echo "EKS_CLUSTER_NAMESPACE=$EKS_CLUSTER_NAMESPACE"
    echo "EKSLBCONTROLLER_SERVICEACCOUNT_NAME=$EKSLBCONTROLLER_SERVICEACCOUNT_NAME"
    echo "EKSLBCONTROLLER_IAMROLE_NAME=$EKSLBCONTROLLER_IAMROLE_NAME"
    echo "EKSLBCONTROLLER_IAMPOLICY_ARN=$EKSLBCONTROLLER_IAMPOLICY_ARN"
    echo "GITHUB_USERNAME=$GITHUB_USERNAME"
    echo "GITHUB_TOKEN=$GITHUB_TOKEN"
    echo "ARGOCD_CLUSTER_NAME=$ARGOCD_CLUSTER_NAME"
    echo "ARGOCD_APPLICATION_HELMREPO=$ARGOCD_APPLICATION_HELMREPO"
    echo "ARGOCD_APPLICATION_HELMVALUES_FILENAME=$ARGOCD_APPLICATION_HELMVALUES_FILENAME"
    echo "ARGOCD_APPLICATION_NAME=$ARGOCD_APPLICATION_NAME"
    echo "ARGOCD_APPSVCNAME_HELMPATH=$ARGOCD_APPSVCNAME_HELMPATH"


    #set_aws_credentials
    update_kubeconfig
    #create_namespace
    #install_metrics_server
    #add_helm_repo
    #install_aws_load_balancer_controller   
    install_nginx_ingress    
    deploy_cluster_autoscaler
    #install_prometheus
    #install_externalsecretoperator
}

# Call main function with command-line arguments
main "$@"
