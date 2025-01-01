/*
output "bastionhost_iam_role_arn" {
  value = aws_iam_role.admin_role.arn
}*/

output "efs_filesystem_id" {
  value = aws_efs_file_system.efs.id
}
