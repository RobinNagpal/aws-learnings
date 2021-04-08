terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}


variable "environment" {
  default = "prod"
}


resource "aws_s3_bucket" "www" {
  bucket = "aws.fomo.dev"
  acl    = "public-read"
  policy = <<-POLICY
    {
      "Version": "2012-10-17",
      "Statement": [{
        "Sid": "AddPerm",
        "Effect": "Allow",
        "Principal": "*",
        "Action": ["s3:GetObject"],
        "Resource": ["arn:aws:s3:::aws.fomo.dev/*"]
      }]
    }
    POLICY
  website {
    index_document = "index.html"
    error_document = "404.html"
  }

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

resource "aws_route53_zone" "main" {
  name = "aws.fomo.dev"

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

resource "aws_route53_record" "main-ns" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "aws.fomo.dev"
  type    = "A"
  alias {
    name                   = aws_s3_bucket.www.website_endpoint
    zone_id                = aws_s3_bucket.www.hosted_zone_id
    evaluate_target_health = false
  }
}


output "aws_route53_zone_ns" {
  value = aws_route53_zone.main.name_servers
}
