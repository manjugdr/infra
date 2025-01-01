variable "environment" {
  description = "Environment -Dev/QA/Stage/Prod"
}
variable "project_name" {
  description = "ProjectName" 
}
variable "vpc_id" {
    description = "vpc id"
    type = string
}

#Elasticcahe replication group

variable "replication_group_id" {
    description = "replication_group_id"
}
variable "replication_group_description" {
    description = "replication_group_description"
}
variable "replication_group_engine" {
    description = "replication_group_engine"
}
variable "replication_group_engine_version" {
    description = "replication_group_engine_version"
}
variable "replication_group_node_type" {
    description = "replication_group_node_type"
}
variable "replication_group_num_cache_clusters" {
    description = "replication_group_num_cache_clusters"
}
variable "replication_group_multi_az_enabled" {
    description = "replication_group_multi_az_enabled"
}
variable "replication_group_automatic_failover_enabled" {
    description = "replication_group_automatic_failover_enabled"
}
variable "replication_group_port" {
    description = "replication_group_port"
}
variable "replication_group_snapshot_retention_limit" {
    description = "replication_group_snapshot_retention_limit"
}
variable "replication_group_snapshot_window" {
    description = "replication_group_snapshot_window"
}
variable "replication_group_at_rest_encryption_enabled" {
    description = "replication_group_at_rest_encryption_enabled"
}
variable "replication_group_transit_encryption_enabled" {
    description = "replication_group_transit_encryption_enabled"
}
variable "replication_group_apply_immediately" {
    description = "replication_group_apply_immediately"
}
variable "replication_group_maintenance_window" {
    description = "replication_group_maintenance_window"
}
variable "replication_group_log_type_slow_log" {
  type    = string
  default = "slow-log"
}
variable "replication_group_log_type_engine_log" {
  type    = string
  default = "engine-log"
}
variable "replication_group_log_destination_type" {
  description = "Destination type for log delivery"
  type        = string
  default     = "cloudwatch-logs"  # Default to CloudWatch Logs
}
variable "replication_group_log_format" {
  description = "Log format for log delivery"
  type        = string
}

#Elasticcache Additional settings

variable "subnet_ids_for_elasticcache" {
    description = "subnet_ids_for_elasticcache"
}
variable "elasticcache_subnet_group_name" {
    description = "elasticcache_subnet_group_name"
}

variable "elasticcache_subnet_group_description" {
    description = "elasticcache_subnet_group_description"
}
variable "elasticcache_param_group_name" {
    description = "elasticcache_param_group_name"
}
variable "elasticcache_param_group_family" {
    description = "elasticcache_param_group_family"
}
variable "elasticcache_param_group_description" {
    description = "elasticcache_param_group_description"
}
variable "elasticcache_cwlog_group_name" {
    description = "elasticcache_cwlog_group_name"
}
variable "elasticcache_cwlog_group_retentiondays" {
    description = "elasticcache_cwlog_group_retentiondays"
}
variable "elasticcache_sg_ingress_rules" {
  description = "SG for elasticcahe"
}
