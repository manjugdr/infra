#!/bin/bash

# Function to display usage
display_usage() {
    echo "Usage: $0 <AWS_ACCESS_KEY> <AWS_SECRET_KEY> <AWS_REGION> <EKS_CLUSTER_NAME> <EKS_CLUSTER_URL> <EKS_CLUSTER_ARN> <EKS_CLUSTER_NAMESPACE> <EKSLBCONTROLLER_SERVICEACCOUNT_NAME> <EKSLBCONTROLLER_IAMROLE_NAME> <EKSLBCONTROLLER_IAMPOLICY_ARN> <GITHUB_USERNAME> <GITHUB_TOKEN> <ARGOCD_CLUSTER_NAME> <ARGOCD_APPLICATION_HELMREPO> <ARGOCD_APPLICATION_HELMVALUES_FILENAME> <ARGOCD_APPLICATION_NAME> <ARGOCD_APPSVCNAME_HELMPATH>"
    exit 1
}
create_namespace() {
    echo "===========kubectl create application namespace==========="
    kubectl create namespace $EKS_CLUSTER_NAMESPACE
}
# Function to export AWS credentials
set_aws_credentials() {
    echo "==============Exporting AWS credentials=============="
    export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY"
    export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_KEY"
    aws configure list
}


# Function to install Docker
install_docker() {
    echo "==============Install Docker=============="
    sudo yum install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ec2-user
}

# Function to install git
install_git() {
    echo "==============Install git=============="
    sudo yum install -y git
}

# Function to install mariaDB CLI
install_mariadbcli() {
    echo "==============Install MariaDB CLI=============="
    sudo dnf update -y
    sudo dnf install mariadb105
}
# Function to install kubectl
install_kubectl() {
    echo "==============Install kubectl=============="
    curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.29.0/2024-01-04/bin/linux/amd64/kubectl
    chmod +x ./kubectl
    mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
}

# Function to install eksctl
install_eksctl() {
    echo "==============Install eksctl=============="
    wget https://github.com/eksctl-io/eksctl/releases/download/v0.175.0/eksctl_Linux_amd64.tar.gz
    tar -xvzf eksctl_Linux_amd64.tar.gz -C /tmp
    sudo cp /tmp/eksctl /usr/local/bin/
    eksctl version
}

# Function to update EKS cluster kubeconfig
update_kubeconfig() {
    echo "==============Update EKS cluster kubeconfig=============="
    aws eks --region "$AWS_REGION" update-kubeconfig --name "$EKS_CLUSTER_NAME"
}

# Function to install Helm
install_helm() {
    echo "==============Install Helm=============="
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh && chmod 700 get_helm.sh && ./get_helm.sh
}

# Function to install metrics server
install_metrics_server() {
    echo "==============Install metrics server=============="
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
    kubectl get deployment metrics-server -n kube-system
}

# Function to add helm repo for AWS Load Balancer controller
add_helm_repo() {
    echo "==============Helm repo to add AWS Load balancer=============="
    helm repo add eks https://aws.github.io/eks-charts
    helm repo update
}

# Function to install AWS Load Balancer controller with eksctl
install_aws_load_balancer_controller() {
    echo "==============Install AWS Load Balancer Controller=============="
    eksctl utils associate-iam-oidc-provider --region="$AWS_REGION" --cluster="$EKS_CLUSTER_NAME" --approve
    eksctl create iamserviceaccount --cluster="$EKS_CLUSTER_NAME" --namespace=kube-system --name="$EKSLBCONTROLLER_SERVICEACCOUNT_NAME" --role-name="$EKSLBCONTROLLER_IAMROLE_NAME" --attach-policy-arn="$EKSLBCONTROLLER_IAMPOLICY_ARN" --region="$AWS_REGION" --approve
    helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName="$EKS_CLUSTER_NAME" --set serviceAccount.create=false --set serviceAccount.name="$EKSLBCONTROLLER_SERVICEACCOUNT_NAME"
}

# Function to install nginx ingress controller that hosts all microservices
install_nginx_ingress() {
    echo "==============Install nginx ingress controller==========="
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    ##install_nginx_ingress  
    helm upgrade -i ingress-nginx ingress-nginx/ingress-nginx \
    --namespace kube-system \
    --set controller.service.type=LoadBalancer \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-name"="commonservices-dev-nlb" \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-type"="external" \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-scheme"="internet-facing" \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-nlb-target-type"="ip"
}

# Function to deploy cluster autoscaler
deploy_cluster_autoscaler() {
    echo "==============Deploy the cluster autoscaler=============="
    sed "s/<CLUSTER_NAME>/$EKS_CLUSTER_NAME/g" files/cluster-autoscaler-autodiscover.yaml | kubectl apply -f -
    kubectl -n kube-system annotate deployment.apps/cluster-autoscaler cluster-autoscaler.kubernetes.io/safe-to-evict="false"
}

# Function to install Prometheus and Grafana stack
install_prometheus_grafana() {
    echo "==============Install Prometheus Grafana stack=============="
    kubectl create namespace monitoring
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    helm upgrade prometheus-grafana prometheus-community/kube-prometheus-stack -f files/values-prometheusgrafana.yaml -n monitoring
}

# Function to install secretmanager
install_externalsecretoperator() {
  echo "===Install External Secret Oprator to fetch secrets==="
  helm repo add external-secrets https://charts.external-secrets.io
  helm repo update
  helm install external-secrets external-secrets/external-secrets --namespace $EKS_CLUSTER_NAMESPACE
}
# Function to install Argo CD
install_argo_cd() {
    echo "==============Install ArgoCD=============="
    aws eks --region "$AWS_REGION" update-kubeconfig --name "$ARGOCD_CLUSTER_NAME"
    kubectl create namespace "$ARGOCD_NAMESPACE"
    kubectl apply -n "$ARGOCD_NAMESPACE" -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    #kubectl patch svc "$ARGOCD_SERVICE_NAME" -n "$ARGOCD_NAMESPACE" -p '{"metadata": {"annotations": {"service.beta.kubernetes.io/aws-load-balancer-type": "nlb"}}, "spec": {"type": "LoadBalancer"}}'
    kubectl apply -f files/argocd-tls.yaml -n "$ARGOCD_NAMESPACE"
    kubectl apply -f files/argocd-ingress-https.yaml -n "$ARGOCD_NAMESPACE"
    kubectl describe svc "$ARGOCD_SERVICE_NAME" -n "$ARGOCD_NAMESPACE"
    
    # Wait until the External IP is available
    echo "==========Get Argo IP========="
    while true; do
        ARGOCD_EXTERNAL_IP=$(kubectl get ingress argocd-ingress -n "$ARGOCD_NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
        if [ -n "$ARGOCD_EXTERNAL_IP" ]; then
            break
        fi
        echo "Waiting for external IP..."
        sleep 10
    done
    
    echo "Load Balancer URL: http://$ARGOCD_EXTERNAL_IP"
    
    echo "==============Download Argo CLI=============="
    curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
    
    echo "=============Install ArgoCLI================="
    sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
    
    echo "========Retrieve the initial password from the Kubernetes secret======"
    INITIAL_PASSWORD=$(kubectl -n "$ARGOCD_NAMESPACE" get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode)
    echo "INTITIALPASSWORD=$INITIAL_PASSWORD"
    
    echo "==========Log in to Argo CD using the argocd CLI======"
    argocd login "$ARGOCD_EXTERNAL_IP" --username admin --password "$INITIAL_PASSWORD" --insecure
    # Add commonservices cluster to argocd- 
    # skipping the below step as the argocd itself is deployed in commonservices cluster and 
    # it is available by default

    #echo "=========Add powerpay cluster to argocd======="
    #argocd cluster add "$EKS_CLUSTER_ARN" --name "$EKS_CLUSTER_NAME" -y
    
    # Add the GitHub repo where the manifest files are stored
    echo "=======Add commonservices helm repo=========="
    argocd repo add "$ARGOCD_APPLICATION_HELMREPO" --username "$GITHUB_USERNAME" --password "$GITHUB_TOKEN"

    kubectl config set-context --current --namespace=argocd    
    mkdir -p ~/argocd && cd ~/argocd

    # Split ARGOCD_APPSVCNAME_HELMPATH into individual components based on space delimiter
    IFS='#' read -ra COMPONENTS <<< "$ARGOCD_APPSVCNAME_HELMPATH"

    # Loop through each component (e.g., "app1-path1", "app2-path2")
    for component in "${COMPONENTS[@]}"; do
        # Split component into app and path based on ":"
        IFS=':' read -r APPSVC HELMPATH <<< "$component"       
        # Create YAML file based on app and path
        /usr/bin/cat <<EOF > "${ARGOCD_APPLICATION_NAME}${APPSVC}-${EKS_CLUSTER_NAMESPACE}-argocd-app.yaml"
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${ARGOCD_APPLICATION_NAME}${APPSVC}
  namespace: $ARGOCD_NAMESPACE
spec:
  project: default
  source:
    repoURL: '$ARGOCD_APPLICATION_HELMREPO'
    targetRevision: HEAD
    path: '$HELMPATH'
    helm:
      valueFiles:
        - $ARGOCD_APPLICATION_HELMVALUES_FILENAME
  destination:
    server: 'https://kubernetes.default.svc'
    namespace: $EKS_CLUSTER_NAMESPACE
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF
        echo "Created ${ARGOCD_APPLICATION_NAME}${APPSVC}-${EKS_CLUSTER_NAMESPACE}-argocd-app.yaml"
        #kubectl apply -f "${ARGOCD_APPLICATION_NAME}${APPSVC}-${EKS_CLUSTER_NAMESPACE}-argocd-app.yaml" -n "$ARGOCD_NAMESPACE"
    done
}
push_nginxlogs_timezone() {
    echo "==============Push ingress controller logs and set timezone for nginx==========="
    aws eks --region $AWS_REGION update-kubeconfig --name $EKS_CLUSTER_NAME
    kubectl patch deployment ingress-nginx-controller -n kube-system --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/env", "value": [{"name": "TZ", "value": "Asia/Kolkata"}]}]'
    kubectl patch deployment ingress-nginx-controller -n kube-system --type=json -p='[
  {
    "op": "add",
    "path": "/spec/template/spec/volumes",
    "value": [
      {
        "name": "log-volumes",
        "persistentVolumeClaim": {
          "claimName": "commonservicesv1-0nginxlog-commonservicesnginxingresslogschart-logs-pvc"
        }
      }
    ]
  },
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/volumeMounts",
    "value": [
      {
        "name": "log-volumes",
        "mountPath": "/var/log/nginx"
      }
    ]
  }
]'
    ##install_nginx_ingress  
    helm upgrade -i ingress-nginx ingress-nginx/ingress-nginx \
    --namespace kube-system \
    --set controller.service.type=LoadBalancer \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-name"="commonservices-dev-nlb" \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-type"="external" \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-scheme"="internet-facing" \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-nlb-target-type"="ip"
}
# Main function to execute all functions based on arguments
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


    # Call functions
    create_namespace
  #  set_aws_credentials
  #  install_docker
  #  install_git
  #  install_kubectl
  #  install_eksctl
    update_kubeconfig
  #  install_helm
  #  install_metrics_server
  #  add_helm_repo
  #  install_aws_load_balancer_controller
    install_nginx_ingress
  #  deploy_cluster_autoscaler
  #  install_prometheus_grafana
    install_externalsecretoperator
    install_argo_cd
    push_nginxlogs_timezone
}

# Call main function with arguments
main "$@"
