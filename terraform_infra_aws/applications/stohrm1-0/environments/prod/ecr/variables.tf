#ECR

# Define a list of repository names
variable "repository_names" {
  type    = list(string)
}
variable "project_name" {
  description = "ProjectName" 
  default = "powerpay2.0"
}
variable "environment" {
  description = "Environment -Dev/QA/Stage/Prod"
  default = "dev"
}

# Common
variable "aws_region" {
  description = "AWS region"
}
variable "bucket_name" {
  description = "BucketName"
  default = "default-tfstate"
}
