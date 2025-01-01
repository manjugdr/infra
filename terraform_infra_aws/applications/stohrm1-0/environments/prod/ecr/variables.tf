#ECR

# Define a list of repository names
variable "repository_names" {
  type    = list(string)
}
variable "project_name" {
  description = "ProjectName" 
  default = "powerpay2.0"
}
