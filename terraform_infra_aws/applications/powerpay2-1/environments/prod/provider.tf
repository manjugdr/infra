terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.35.0"
    }
  }
  backend "s3" {
    bucket  = "ascent-terraform-statefile"
    key    = "powerpayv2-1/prod/terraform.tfstate"
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

