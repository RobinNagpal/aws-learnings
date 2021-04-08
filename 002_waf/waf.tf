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
  bucket = "tutelage.dev"
  acl    = "public-read"
  website {
    index_document = "index.html"
    error_document = "404.html"
  }

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

resource "aws_s3_bucket" "www-logs" {
  bucket = "aws-logs.tutelage.dev"
  acl    = "public-read"

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

resource "aws_route53_zone" "main" {
  name = "tutelage.dev"

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

locals {
  s3_origin_id = "s3-origin-${aws_s3_bucket.www.bucket}"
}

resource "aws_cloudfront_origin_access_identity" "www_origin_access_identity" {
  comment = "comment"
}
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.www.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.www_origin_access_identity.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "www_polict" {
  bucket = aws_s3_bucket.www.id
  policy = data.aws_iam_policy_document.s3_policy.json
}


resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.www.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/${aws_cloudfront_origin_access_identity.www_origin_access_identity.id}"
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.www-logs.bucket_domain_name
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 60
    max_ttl                = 120
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  tags = {
    Environment = "production"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_route53_record" "main-ns" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "tutelage.dev"
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

output "aws_route53_zone_ns" {
  value = aws_route53_zone.main.name_servers
}


