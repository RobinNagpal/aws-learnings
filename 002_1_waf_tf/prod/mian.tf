terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}


provider "aws" {
  region = "us-east-1"
}

variable "environment" {
  default = "prod"
}

module "local_way" {
  source = "./../modules/waf"
}
