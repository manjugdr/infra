
output "bastionhost_publicip" {
  value = module.ec2.bastionhost_publicip
}

output "bastionhost_privateip" {
  value = module.ec2.bastionhost_privateip
}
