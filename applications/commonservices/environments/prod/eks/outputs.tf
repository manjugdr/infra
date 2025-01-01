output "kubeconfig-certificate-authority-data" {
  value = module.eks.kubeconfig-certificate-authority-data
}

output "cluster-arn" {
  value = module.eks.cluster-arn
}
output "cluster-endpoint"{
    value = module.eks.cluster-endpoint
}
output "cluster-status" {
  value =  module.eks.cluster-status
}

output "ekslbcontroller_iampolicyarn" {
value = module.eks.ekslbcontroller_iampolicyarn
}
output "clustername" {
  value =  module.eks.clustername
}
output "eks_cluster_serverurl" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.eks_cluster_serverurl
}