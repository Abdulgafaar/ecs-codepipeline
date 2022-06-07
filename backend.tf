terraform {
  backend "s3" {
    bucket         = "abdul-terraform-backend-state"
    key            = "terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-statetable"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}bash: cd: modules/: Permission denied
