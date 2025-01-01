/*
output "bastionhost_iam_role_arn" {
  value = aws_iam_role.admin_role.arn
}*/

output "ec2mongo_privateip" {
  value = aws_instance.ec2mongo_host.private_ip
}
