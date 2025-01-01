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

variable "rds_db_count" {
  description = "No.of RDS instances to be created"
}
variable "rds_subnetgroup_name" {
  description = "rds_subnetgroup_name"
}
variable "subnet_ids_for_rds" {
  description = "private subnet id for rds subnet group"
}
variable "rds_db_allocated_storage" {
  description = "allocated_storage"
}
variable "rds_db_engine" {
  description = "rds db engine-mysql/postgresql/mariadb/mssql"
}
variable "rds_db_engine_version" {
  description = "rds db engine version of -mysql/postgresql/mariadb/mssql"
}
variable "rds_db_instancetype" {
  description = "rds db engine version of -mysql/postgresql/mariadb/mssql"
}
variable "rds_db_identifier" {
  description = "rds db name"
}
variable "rds_db_storagetype" {
  description = "rds db storagetype - gp2/gp3"
}
variable "rds_db_username" {
  description = "rds db username"
}
variable "rds_db_password" {
  description = "rds db password"
}
variable "rds_db_is_skipfinalsnapshot" {
  description = "skipfinalsnapshot - true/false"
}
variable "rds_db_is_publicaccess" {
  description = "To enable public access - true/false"
}
variable "rds_db_max_allocated_storage" {
    description = "Max storage value"
}
variable "rds_db_is_performance_insights_enabled" {
    description = "performance_insights_enabled - true/false"
}
variable "rds_db_performance_insights_retention_period" {
    description = "performance_insights_retention_period"
}

#RDS SG

variable "rdssg_ingress_rules" {
    type = map
}

#RDS Additional settings

variable "rds_db_backup_retention_period" {
    description = "retention days"
}
variable "rds_db_backup_window" {
    description = "date for backup window"
}
variable "rds_db_storage_encrypted" {
    description = "encryption- true/false"
}
variable "rds_db_copy_tags_to_snapshot" {
    description = "copy snapshots- true/false"
} 
variable "rds_db_enable_multi_az" {
    description = "Enable multi-AZ- true/false"
} 
variable "rds_db_deletion_protection" {
    description = "Deletion Protection- true/false"
}
variable "rds_db_enabled_cloudwatch_logs_exports" {
    description = "Enabled logs postgresql/upgrade"
} 

