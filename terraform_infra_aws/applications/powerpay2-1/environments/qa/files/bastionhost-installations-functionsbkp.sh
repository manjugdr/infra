#!/bin/bash 

# Function to display usage
display_usage() {
    echo "Usage: $0 <AWS_ACCESS_KEY> <AWS_SECRET_KEY> <AWS_REGION> <EKS_CLUSTER_NAME> <EKS_CLUSTER_URL> <EKS_CLUSTER_ARN> <EKS_CLUSTER_NAMESPACE> <EKSLBCONTROLLER_SERVICEACCOUNT_NAME> <EKSLBCONTROLLER_IAMROLE_NAME> <EKSLBCONTROLLER_IAMPOLICY_ARN> <GITHUB_USERNAME> <GITHUB_TOKEN> <ARGOCD_CLUSTER_NAME> <ARGOCD_APPLICATION_HELMREPO> <ARGOCD_APPLICATION_HELMVALUES_FILENAME> <ARGOCD_APPLICATION_NAME> <ARGOCD_APPSVCNAME_HELMPATH>"
    exit 1
}

# Function to set AWS credentials
set_aws_credentials() {
    export AWS_ACCESS_KEY_ID=$1
    export AWS_SECRET_ACCESS_KEY=$2
    aws configure list
}

# Function to update kubeconfig for EKS cluster
update_kubeconfig() {
    aws eks --region $AWS_REGION update-kubeconfig --name $1
}

# Function to create Kubernetes application namespace
create_namespace() {
    kubectl create namespace $1
}

# Function to install metrics server
install_metrics_server() {
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
    kubectl get deployment metrics-server -n kube-system
}

# Function to add Helm repo for AWS Load Balancer Controller
add_helm_repo() {
    helm repo add eks https://aws.github.io/eks-charts
    helm repo update
}

# Function to associate IAM OIDC provider and install AWS Load Balancer Controller
install_aws_lb_controller() {
    eksctl utils associate-iam-oidc-provider --region=$AWS_REGION --cluster=$EKS_CLUSTER_NAME --approve
    eksctl create iamserviceaccount --cluster=$EKS_CLUSTER_NAME --namespace=kube-system --name=$1 --role-name=$2 --attach-policy-arn=$3 --region $AWS_REGION --approve
    helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=$EKS_CLUSTER_NAME --set serviceAccount.create=false --set serviceAccount.name=$1
}

# Function to install nginx ingress controller that hosts all microservices
install_nginx_ingress() {
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm upgrade -i ingress-nginx ingress-nginx/ingress-nginx \
    --namespace kube-system \
    --set controller.service.type=LoadBalancer \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-name"="powerpayservicesv2-1-qa-nlb" \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-type"="external" \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-scheme"="internet-facing" \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-nlb-target-type"="ip"
}
# Function to deploy cluster autoscaler
deploy_cluster_autoscaler() {
    sed "s/<CLUSTER_NAME>/$1/g" files/cluster-autoscaler-autodiscover.yaml | kubectl apply -f -
    kubectl -n kube-system annotate deployment.apps/cluster-autoscaler cluster-autoscaler.kubernetes.io/safe-to-evict="false"
}

# Function to install Prometheus server
install_prometheus() {
    kubectl create namespace monitoring
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    helm upgrade prometheus prometheus-community/prometheus -f files/values-prometheus.yaml -n monitoring
}

# Function to install Argo CD and create applications
create_install_argo_app() {
    aws eks --region "$AWS_REGION" update-kubeconfig --name "$1"
    kubectl describe svc "$ARGOCD_SERVICE_NAME" -n "$ARGOCD_NAMESPACE"
    INITIAL_PASSWORD=$(kubectl -n "$ARGOCD_NAMESPACE" get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode)
    echo "===============Get Argo IP=================="
    
    # Wait until the External IP is available
    while true; do
        ARGOCD_EXTERNAL_IP=$(kubectl get svc "$ARGOCD_SERVICE_NAME" -n "$ARGOCD_NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
        if [ -n "$ARGOCD_EXTERNAL_IP" ]; then
            break
        fi
        echo "Waiting for external IP..."
        sleep 10
    done

    # Log in to Argo CD using the argocd CLI
    echo "=======Log in to Argo CD using the argocd CLI======"
    argocd login "$ARGOCD_EXTERNAL_IP" --username admin --password "$INITIAL_PASSWORD" --insecure
    
    # Add stohrm cluster to argocd
    echo "=========Add stohrm cluster to argocd======="
    argocd cluster add "$EKS_CLUSTER_ARN" --name "$EKS_CLUSTER_NAME" -y
    
    # Add the GitHub repo where the manifest files are stored
    echo "=======Add stohrm helm repo=========="
    argocd repo add "$ARGOCD_APPLICATION_HELMREPO" --username "$GITHUB_USERNAME" --password "$GITHUB_TOKEN"

    kubectl config set-context --current --namespace=argocd    
    mkdir -p ~/argocd && cd ~/argocd

    # Split ARGOCD_APPSVCNAME_HELMPATH into individual components based on space delimiter
    IFS='#' read -ra COMPONENTS <<< "$ARGOCD_APPSVCNAME_HELMPATH"

    # Loop through each component (e.g., "app1-path1", "app2-path2")
    for component in "${COMPONENTS[@]}"; do
        # Split component into app and path based on ":"
        IFS=':' read -r APPSVC PATH <<< "$component"       
        # Create YAML file based on app and path
        /usr/bin/cat <<EOF > "${ARGOCD_APPLICATION_NAME}${APPSVC}-${EKS_CLUSTER_NAMESPACE}-argocd-app.yaml"
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: "${ARGOCD_APPLICATION_NAME}${APPSVC}"
  namespace: "$EKS_CLUSTER_NAMESPACE"
spec:
  project: default
  source:
    repoURL: '$ARGOCD_APPLICATION_HELMREPO'
    targetRevision: HEAD
    path: '$PATH'
    helm:
      valueFiles:
        - "$ARGOCD_APPLICATION_HELMVALUES_FILENAME"
  destination:
    server: '$EKS_CLUSTER_URL'
    namespace: "$EKS_CLUSTER_NAMESPACE"
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF
        echo "Created ${ARGOCD_APPLICATION_NAME}${APPSVC}-${EKS_CLUSTER_NAMESPACE}-argocd-app.yaml"
        # kubectl apply -f "${ARGOCD_APPLICATION_NAME}${APP}-${EKS_CLUSTER_NAMESPACE}-argocd-app.yaml" -n "$ARGOCD_NAMESPACE"
    done
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
    ARGOCD_SERVER="argocd.stohrm.in"
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


    echo "==============Setting aws credentials===================="
    set_aws_credentials $AWS_ACCESS_KEY $AWS_SECRET_KEY

    echo "==============Update eks cluster kubeconfig=============="
    update_kubeconfig $EKS_CLUSTER_NAME

    echo "===========kubectl create application namespace==========="
    create_namespace $EKS_CLUSTER_NAMESPACE

    echo "==============Install metrics server====================="
    install_metrics_server

    echo "==========helm repo to add aws Load balancer============="
    add_helm_repo

    echo "==============eksctl commands to install the service account and aws LB=============="
    install_aws_lb_controller $EKSLBCONTROLLER_SERVICEACCOUNT_NAME $EKSLBCONTROLLER_IAMROLE_NAME $EKSLBCONTROLLER_IAMPOLICY_ARN
    
    echo "==============Install nginx ingress controller==========="
    install_nginx_ingress 
    
    echo "===============Deploy the cluster autoscaler============="
    deploy_cluster_autoscaler $EKS_CLUSTER_NAME

    echo "===Install Prometheus server/push Gateway/node exportor==="
    #install_prometheus

    echo "=======Install ArgoCD and create applications============="
    create_install_argo_app $ARGOCD_CLUSTER_NAME $EKS_CLUSTER_URL

}

# Call main function with command-line arguments
main "$@"
