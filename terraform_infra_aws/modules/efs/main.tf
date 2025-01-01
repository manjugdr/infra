

resource "aws_efs_file_system" "efs" {
  creation_token = "${var.project_name}-${var.environment}-efs"
  tags = {
    Name = "${var.project_name}-${var.environment}-efs"
  }

  provisioned_throughput_in_mibps = var.provisioned_throughput_in_mibps  # Provisioned mode
#  lifecycle_management {
#    transition_to_ia = var.lifecycle_management_transition_to_ia  # Lifecycle management
#  }

  encrypted = var.encrypted  # Enable encryption at rest
  performance_mode = var.performance_mode  # Performance mode
  throughput_mode = var.throughput_mode  # Throughput mode
}

resource "aws_efs_mount_target" "efs_mounttarget" {
  count = length(var.private_subnet_ids_for_efs)
  file_system_id = aws_efs_file_system.efs.id
  subnet_id      = var.private_subnet_ids_for_efs[count.index]
  security_groups = [aws_security_group.efs_sg.id]  # Attach security group
}

resource "aws_efs_backup_policy" "policy" {
  file_system_id = aws_efs_file_system.efs.id

  backup_policy {
    status = var.backup_policy_status  # Automatic backups enabled
  }
}
