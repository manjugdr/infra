output "cluster-arn" {
  description = "EKS cluster ARN of this application"
  value       = module.eks.cluster-arn
}
output "eks_cluster_serverurl" {
  description = "EKS cluster server URL of this application"
  value       = module.eks.eks_cluster_serverurl
}
