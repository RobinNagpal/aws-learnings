resource "aws_route53_record" "main-ns" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "aws.tutelage.dev"
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
