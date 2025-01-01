output "elasticcahe_primary_endpoint" {
  description = "Primary endpoint of the ElastiCache Redis replication group"
  value       = module.elasticcache.elasticcahe_primary_endpoint
}

output "elasticcahe_reader_endpoint" {
  description = "Reader endpoint of the ElastiCache Redis replication group"
  value       = module.elasticcache.elasticcahe_reader_endpoint
}
output "cluster-arn" {
  description = "EKS cluster ARN of this application"
  value       = module.eks.cluster-arn
}
output "eks_cluster_serverurl" {
  description = "EKS cluster server URL of this application"
  value       = module.eks.eks_cluster_serverurl
}