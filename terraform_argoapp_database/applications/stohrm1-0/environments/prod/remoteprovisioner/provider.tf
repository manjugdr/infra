terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.35.0"
    }
  }
  backend "s3" {
    bucket  = "ascent-terraform-statefile"
    key    = "stohrmv1-0/prod/remoteprovisionerapp/terraform.tfstate"
    region = "ap-south-1"
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags= {
    ProjectName     = var.project_name
    Environment     = var.environment  
    }
  }
}

