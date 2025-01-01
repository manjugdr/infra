#!/bin/bash 

# Define an array to store arguments
args=("$@")

# Check the number of arguments passed
num_args=${#args[@]}

# Display the arguments
echo "Total number of arguments passed: $num_args"

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
ARGOCD_APPLICATION_HELMPATH=${args[14]}
ARGOCD_APPLICATION_HELMVALUES_FILENAME=${args[15]}
ARGOCD_APPLICATION_NAME=${args[16]}
ARGOCD_SERVER="argocd.stohrm.in"
ARGOCD_NAMESPACE="argocd"
ARGOCD_SERVICE_NAME="argocd-server"


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
echo "ARGOCD_APPLICATION_HELMPATH=$ARGOCD_APPLICATION_HELMPATH"
echo "ARGOCD_APPLICATION_HELMVALUES_FILENAME=$ARGOCD_APPLICATION_HELMVALUES_FILENAME"
echo "ARGOCD_APPLICATION_NAME=$ARGOCD_APPLICATION_NAME"


echo "==============Setting aws credentials=============="

# Create AWS configuration directory if it doesn't exist
#mkdir -p ~/.aws

# Write AWS credentials to the credentials file
#cat <<EOF > ~/.aws/credentials
#[default]
#aws_access_key_id = $AWS_ACCESS_KEY
#aws_secret_access_key = $AWS_SECRET_KEY
#EOF

# Write AWS region to the configuration file
#cat <<EOF > ~/.aws/config
#[default]
#region = $AWS_REGION
#EOF

#echo "AWS credentials set successfully."

echo "==============Exporting aws credentials=============="
export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY
echo "$AWS_ACCESS_KEY"
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_KEY
echo "$AWS_SECRET_KEY" 

aws configure list

echo "==============Update eks cluster kubeconfig=============="
aws eks --region $AWS_REGION update-kubeconfig --name $EKS_CLUSTER_NAME 

echo "==============kubectl get nodes=============="
kubectl get nodes 
kubectl create namespace $EKS_CLUSTER_NAMESPACE

echo "==============Install metrics server=============="
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl get deployment metrics-server -n kube-system

echo "==============helm repo to add aws Load balancer=============="
helm repo add eks https://aws.github.io/eks-charts  
helm repo update  

echo "==============eksctl commands to install the service account and aws LB=============="
eksctl utils associate-iam-oidc-provider --region=$AWS_REGION --cluster=$EKS_CLUSTER_NAME --approve  
eksctl create iamserviceaccount --cluster=$EKS_CLUSTER_NAME --namespace=kube-system --name=$EKSLBCONTROLLER_SERVICEACCOUNT_NAME --role-name=$EKSLBCONTROLLER_IAMROLE_NAME --attach-policy-arn=$EKSLBCONTROLLER_IAMPOLICY_ARN --region $AWS_REGION --approve  
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=$EKS_CLUSTER_NAME --set serviceAccount.create=false --set serviceAccount.name=$EKSLBCONTROLLER_SERVICEACCOUNT_NAME

echo "===============Deploy the cluster autoscaler==========================="
sed "s/<CLUSTER_NAME>/$EKS_CLUSTER_NAME/g" files/cluster-autoscaler-autodiscover.yaml | kubectl apply -f -
kubectl -n kube-system annotate deployment.apps/cluster-autoscaler cluster-autoscaler.kubernetes.io/safe-to-evict="false"

#######Install Prometheus server, push Gateway and node exportor#######
echo "########Install Prometheus server/push Gateway/node exportor########"
kubectl create namespace monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade prometheus prometheus-community/prometheus -f files/values-prometheus.yaml -n monitoring


echo "==============Install ArgoCD=============="
aws eks --region $AWS_REGION update-kubeconfig --name $ARGOCD_CLUSTER_NAME  

kubectl describe svc $ARGOCD_SERVICE_NAME -n $ARGOCD_NAMESPACE  #verify installation

# Retrieve the initial password from the Kubernetes secret
INITIAL_PASSWORD=$(kubectl -n $ARGOCD_NAMESPACE get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode)

echo "==========Get Argo IP========="
# Wait until the External IP is available
while true; do
  ARGOCD_EXTERNAL_IP=$(kubectl get svc $ARGOCD_SERVICE_NAME -n $ARGOCD_NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
  if [ -n "$ARGOCD_EXTERNAL_IP" ]; then
    break
  fi
  echo "Waiting for external IP..."
  sleep 10
done

# Log in to Argo CD using the argocd CLI
echo "=======Log in to Argo CD using the argocd CLI======"
argocd login $ARGOCD_EXTERNAL_IP --username admin --password $INITIAL_PASSWORD --insecure
# Add stohrm cluster to argocd
echo "=========Add stohrm cluster to argocd======="
argocd cluster add $EKS_CLUSTER_ARN --name $EKS_CLUSTER_NAME -y
#create the github repo where the manifest files are stored:
echo "========Add stohrm helm repo=========="
argocd repo add $ARGOCD_APPLICATION_HELMREPO --username $GITHUB_USERNAME --password $GITHUB_TOKEN

#create an argo application
echo "========create stohrm argo application========"
mkdir -p ~/argocd && cd ~/argocd
cat <<EOF > $ARGOCD_APPLICATION_NAME-argocd-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: $ARGOCD_APPLICATION_NAME
  namespace: $ARGOCD_NAMESPACE
spec:
  project: default
  source:
    repoURL: '$ARGOCD_APPLICATION_HELMREPO'
    targetRevision: HEAD
    path: '$ARGOCD_APPLICATION_HELMPATH'
    helm:
      valueFiles:
        - $ARGOCD_APPLICATION_HELMVALUES_FILENAME
  destination:
    server: '$EKS_CLUSTER_URL'
    namespace: $EKS_CLUSTER_NAMESPACE
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

kubectl config set-context --current --namespace=argocd
#kubectl apply -f $ARGOCD_APPLICATION_NAME-argocd-app.yaml -n $ARGOCD_NAMESPACE

###Argo Application updated successfully#####

