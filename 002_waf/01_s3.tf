resource "aws_s3_bucket" "www" {
  bucket = "aws.tutelage.dev"
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
  bucket = "aws-logs.aws.tutelage.dev"
  acl    = "public-read"

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
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
