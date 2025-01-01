#!/bin/bash

# Function to display usage
display_usage() {
    echo "Usage: $0 <AWS_ACCESS_KEY> <AWS_SECRET_KEY> <AWS_REGION> <EKS_CLUSTER_NAME> <EKS_CLUSTER_URL> <EKS_CLUSTER_ARN> <EKS_CLUSTER_NAMESPACE> <EKSLBCONTROLLER_SERVICEACCOUNT_NAME> <EKSLBCONTROLLER_IAMROLE_NAME> <EKSLBCONTROLLER_IAMPOLICY_ARN> <GITHUB_USERNAME> <GITHUB_TOKEN> <ARGOCD_CLUSTER_NAME> <ARGOCD_APPLICATION_HELMREPO> <ARGOCD_APPLICATION_HELMVALUES_FILENAME> <ARGOCD_APPLICATION_NAME> <ARGOCD_APPSVCNAME_HELMPATH>"
    exit 1
}

# Function to install Argo CD
create_argocd_applications() {
    echo "==============Install ArgoCD=============="
    aws eks --region "$AWS_REGION" update-kubeconfig --name "$ARGOCD_CLUSTER_NAME"
    
    # Wait until the External IP is available
    echo "==========Get Argo IP========="
    while true; do
        ARGOCD_EXTERNAL_IP=$(kubectl get ingress argocd-ingress -n "$ARGOCD_NAMESPACE" -o jsonpath='{.spec.rules[].host}')
        if [ -n "$ARGOCD_EXTERNAL_IP" ]; then
            break
        fi
        echo "Waiting for external IP..."
        sleep 10
    done
    
    echo "Load Balancer URL: http://$ARGOCD_EXTERNAL_IP"

    
    echo "========Retrieve the initial password from the Kubernetes secret======"
    INITIAL_PASSWORD=$(kubectl -n "$ARGOCD_NAMESPACE" get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode)
    echo "INTITIALPASSWORD=$INITIAL_PASSWORD"
    
    echo "==========Log in to Argo CD using the argocd CLI======"
    argocd login "$ARGOCD_EXTERNAL_IP" --username admin --password "$INITIAL_PASSWORD" --insecure
    # Add commonservices cluster to argocd- 
    # skipping the below step as the argocd itself is deployed in commonservices cluster and 
    # it is available by default

    echo "=========Add powerpay cluster to argocd======="
    argocd cluster add "$EKS_CLUSTER_ARN" --name "$EKS_CLUSTER_NAME" -y
    
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
        local max_wait_time=600  # 10 minutes in seconds
        local sleep_interval=10  # Interval to check the status
        kubectl apply -f "${ARGOCD_APPLICATION_NAME}${APPSVC}-${EKS_CLUSTER_NAMESPACE}-argocd-app.yaml" -n "$ARGOCD_NAMESPACE"
        # Initialize the wait time counter
        local elapsed_time=0
            # Wait for the application to be 'Healthy' and 'Synced'
        while true; do
          app_status=$(kubectl get application "${ARGOCD_APPLICATION_NAME}${APPSVC}" -n "${NAMESPACE}" -o jsonpath="{.status.health.status}")
          sync_status=$(kubectl get application "${ARGOCD_APPLICATION_NAME}${APPSVC}" -n "${NAMESPACE}" -o jsonpath="{.status.sync.status}")

          if [[ "${app_status}" == "Healthy" && "${sync_status}" == "Synced" ]]; then
            echo "${ARGOCD_APPLICATION_NAME}${APPSVC} is successfully deployed."
            break
          fi
        
          if [[ "${elapsed_time}" -ge "${max_wait_time}" ]]; then
            echo "Timed out waiting for ${ARGOCD_APPLICATION_NAME}${APPSVC} to become Healthy and Synced."
            exit 1
          fi

          echo "Waiting for ${ARGOCD_APPLICATION_NAME}${APPSVC} to be Healthy and Synced..."
          sleep "${sleep_interval}"
          elapsed_time=$((elapsed_time + sleep_interval))
        done

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
    --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-name"="commonservices-prod-nlb" \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-type"="external" \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-scheme"="internet-facing" \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-nlb-target-type"="ip"
}
# Main function to execute all functions based on arguments
main() {
    # Check if all required arguments are provided
    if [ $# -ne 11 ]; then
        echo "Total number of arguments passed: $#"
        display_usage
    fi

    # Array to store arguments
    args=("$@")

    # Assign arguments to variables

    AWS_REGION=${args[0]}
    EKS_CLUSTER_NAME=${args[1]}
    EKS_CLUSTER_ARN=${args[2]}
    EKS_CLUSTER_NAMESPACE=${args[3]}
    GITHUB_USERNAME=${args[4]}
    GITHUB_TOKEN=${args[5]}
    ARGOCD_CLUSTER_NAME=${args[6]}
    ARGOCD_APPLICATION_HELMREPO=${args[7]}
    ARGOCD_APPLICATION_HELMVALUES_FILENAME=${args[8]}
    ARGOCD_APPLICATION_NAME=${args[9]}
    ARGOCD_APPSVCNAME_HELMPATH=${args[10]}
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
    create_argocd_applications
    push_nginxlogs_timezone
}

# Call main function with arguments
main "$@"
