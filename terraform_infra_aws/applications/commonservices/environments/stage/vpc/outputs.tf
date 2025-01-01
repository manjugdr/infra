output "vpc_id" {
  description = "The ID of the created VPC"
  value       = module.vpc.vpc_id
}
output "public_subnet_ids" {
  description = "The ID of the public subnet"
  value       = module.vpc.public_subnet_ids
}
output "private_subnet_ids" {
  description = "The ID of the private subnet"
  value       = module.vpc.private_subnet_ids
}
output "private_subnet_tags" {
  description = "The ID of the private subnet"
  value       = module.vpc.private_subnet_tags
}
output "public_subnet_tags" {
  description = "The ID of the private subnet"
  value       = module.vpc.public_subnet_tags
}
output "public_subnet_cidr" {
  description = "The ID of the private subnet"
  value       = module.vpc.public_subnet_cidr
}
output "private_subnet_cidr" {
  description = "The ID of the private subnet"
  value       = module.vpc.private_subnet_cidr
}