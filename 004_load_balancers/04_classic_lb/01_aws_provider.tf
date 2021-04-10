terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "s3" {
    bucket = "aws-learnings-robin-nagpal"
    key    = "terraform-state/004_load_balancers/04_classic_lb"
    region = "us-east-1"
  }
}


provider "aws" {
  region = "us-east-1"
}


variable "environment" {
  default = "prod"
}
