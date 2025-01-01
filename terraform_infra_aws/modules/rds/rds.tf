# Define the parameter group only if the engine is PostgreSQL
resource "aws_db_parameter_group" "custom_parameter_group" {
  count       = var.rds_db_engine[0] == "postgres" ? var.rds_db_count : 0 
  name        = "${var.rds_db_identifier[count.index]}-parametergroup"
  family      = "postgres14"  # Change to your PostgreSQL version family
  description = "Custom parameter group for postgres14"

  parameter {
    name  = "timezone"
    value = "Asia/Kolkata"
    apply_method = "pending-reboot"
  }
  parameter {
    name  ="shared_preload_libraries"
    value = "pg_cron"
    apply_method = "pending-reboot"
  }
}

#rds group
resource "aws_db_subnet_group" "rds" {
  name       = var.rds_subnetgroup_name
  subnet_ids = var.subnet_ids_for_rds
  tags = {
    "Name" = "${var.project_name}-${var.environment}-rdsdbsubnetgroup"
  }
}

# Create the RDS MySQL instance
resource "aws_db_instance" "rds_db" {
  count = var.rds_db_count 
  allocated_storage    = var.rds_db_allocated_storage[count.index]
  engine               = var.rds_db_engine[count.index]
  engine_version       = var.rds_db_engine_version[count.index]
  instance_class       = var.rds_db_instancetype[count.index]
  identifier           = var.rds_db_identifier[count.index]
  storage_type         = var.rds_db_storagetype[count.index] 
  username             = var.rds_db_username[count.index]
  password             = var.rds_db_password[count.index]
  parameter_group_name = var.rds_db_engine[count.index] == "postgres" ? aws_db_parameter_group.custom_parameter_group[count.index].name : null
  skip_final_snapshot  = var.rds_db_is_skipfinalsnapshot[count.index]
  publicly_accessible  = var.rds_db_is_publicaccess[count.index]
  db_subnet_group_name  = aws_db_subnet_group.rds.id
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  max_allocated_storage  = var.rds_db_max_allocated_storage[count.index]
  performance_insights_enabled = var.rds_db_is_performance_insights_enabled[count.index]
  performance_insights_retention_period = var.rds_db_performance_insights_retention_period[count.index]

  #Additional settings
  //backup_retention_period = var.rds_db_backup_retention_period[count.index]

  #To enable automated backups
  backup_window = var.rds_db_backup_window[count.index]
  storage_encrypted = var.rds_db_storage_encrypted[count.index]
  copy_tags_to_snapshot = var.rds_db_copy_tags_to_snapshot[count.index]
  multi_az = var.rds_db_enable_multi_az[count.index]
  deletion_protection = var.rds_db_deletion_protection[count.index]
  enabled_cloudwatch_logs_exports = var.rds_db_enabled_cloudwatch_logs_exports
   tags = {
    "Name" = "${var.project_name}-${var.environment}-rdsdb-${count.index}"
 }
}
