# Subnet Group for ElastiCache
resource "aws_elasticache_subnet_group" "elasticcache_subnet_group" {
  name       = var.elasticcache_subnet_group_name
  description = var.elasticcache_subnet_group_description
  subnet_ids = var.subnet_ids_for_elasticcache
  tags = {
    Name = "${var.project_name}-${var.environment}-rediscachesubnetgroup"
  }
}

# Parameter Group for Redis Cluster
resource "aws_elasticache_parameter_group" "elasticcache_param_group" {
  name        = var.elasticcache_param_group_name
  family      = var.elasticcache_param_group_family
  description = var.elasticcache_param_group_description

#  parameter {
#    name  = "slowlog-log-slower-than"
#    value = "10000"
#  }
# Add more parameters as needed
}

resource "aws_cloudwatch_log_group" "elasticcache_cwlog_group" {
  name              = var.elasticcache_cwlog_group_name
  retention_in_days = var.elasticcache_cwlog_group_retentiondays  # Set retention period as needed
  #tags = {
  #  Name = "${var.project_name}-${var.environment}-rediscachelogs"
  #}
}

# ElastiCache Redis Cluster
resource "aws_elasticache_replication_group" "elasticcache_replication_group" {
  replication_group_id          = var.replication_group_id
  description                   = var.replication_group_description
  engine                        = var.replication_group_engine
  engine_version                = var.replication_group_engine_version
  node_type                     = var.replication_group_node_type
  num_cache_clusters            = var.replication_group_num_cache_clusters  # For cluster mode enabled with 1 replica
  multi_az_enabled              = var.replication_group_multi_az_enabled
  automatic_failover_enabled    = var.replication_group_automatic_failover_enabled
  port                          = var.replication_group_port
  subnet_group_name             = aws_elasticache_subnet_group.elasticcache_subnet_group.name
  security_group_ids            = [aws_security_group.elasticcache_sg.id]
  parameter_group_name          = aws_elasticache_parameter_group.elasticcache_param_group.name
  snapshot_retention_limit      = var.replication_group_snapshot_retention_limit # Automatic backups enabled
  snapshot_window               = var.replication_group_snapshot_window  # No preference on window
  at_rest_encryption_enabled    = var.replication_group_at_rest_encryption_enabled
  transit_encryption_enabled    = var.replication_group_transit_encryption_enabled
  apply_immediately             = var.replication_group_apply_immediately
  maintenance_window            = var.replication_group_maintenance_window  # Maintenance window

#  log_delivery_configuration {
#    destination        = aws_cloudwatch_log_group.elasticcache_cwlog_group.arn
#    log_type           = var.replication_group_log_type_slow_log  # Use a variable for the slow log
#    destination_type   = var.replication_group_log_destination_type   # Variable for destination type
#    log_format         = var.replication_group_log_format       # Variable for log format
#  }

#  log_delivery_configuration {
#    destination        = aws_cloudwatch_log_group.elasticcache_cwlog_group.arn
#    log_type           = var.replication_group_log_type_engine_log  # Use a variable for the engine log
#    destination_type   = var.replication_group_log_destination_type    # Variable for destination type
#    log_format         = var.replication_group_log_format           # Variable for log format
#  }

  tags = {
    Name = "${var.project_name}-${var.environment}-rediscache"
  }
}




			 