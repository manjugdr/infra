
# Common
variable "aws_region" {
  description = "AWS region"
}
variable "bucket_name" {
  description = "BucketName"
  default = "default-tfstate"
}
variable "environment" {
  description = "Environment -stage/QA/Stage/Prod"
  default = "stage"
}
variable "project_name" {
  description = "ProjectName" 
  default = "commonservices"
}
variable "aws_access_key_id"{
}
variable "aws_secret_access_key"{
}

#ECR

# Define a list of repository names
variable "repository_names" {
  type    = list(string)
}