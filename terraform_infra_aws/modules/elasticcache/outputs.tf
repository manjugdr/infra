output "elasticcahe_primary_endpoint" {
  description = "Primary endpoint of the ElastiCache Redis replication group"
  value       = aws_elasticache_replication_group.elasticcache_replication_group.primary_endpoint_address
}

output "elasticcahe_reader_endpoint" {
  description = "Reader endpoint of the ElastiCache Redis replication group"
  value       = aws_elasticache_replication_group.elasticcache_replication_group.reader_endpoint_address
}

