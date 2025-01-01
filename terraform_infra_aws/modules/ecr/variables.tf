variable "environment" {
  description = "Environment -Dev/QA/Stage/Prod"
}
variable "project_name" {
  description = "ProjectName" 
}

# Define a list of repository names

variable "repository_names" {
  type    = list(string)
}