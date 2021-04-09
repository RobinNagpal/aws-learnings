resource "aws_route53_zone" "main" {
  name = "aws.tutelage.dev"

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}
