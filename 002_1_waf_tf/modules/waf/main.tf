variable "aws_common_rules_set" {
  type = list(string)
  default = [
    "CrossSiteScripting_BODY",
    "CrossSiteScripting_COOKIE",
    "CrossSiteScripting_QUERYARGUMENTS",
    "CrossSiteScripting_URIPATH",
    "EC2MetaDataSSRF_BODY",
    "EC2MetaDataSSRF_COOKIE",
    "EC2MetaDataSSRF_QUERYARGUMENTS",
    "EC2MetaDataSSRF_URIPATH",
    "GenericLFI_BODY",
    "GenericLFI_QUERYARGUMENTS",
    "GenericLFI_URIPATH",
    "GenericRFI_BODY",
    "GenericRFI_QUERYARGUMENTS",
    "GenericRFI_URIPATH",
    "RestrictedExtensions_QUERYARGUMENTS",
    "RestrictedExtensions_URIPATH",
    "SizeRestrictions_BODY",
    "SizeRestrictions_Cookie_HEADER",
    "SizeRestrictions_QUERYSTRING",
    "SizeRestrictions_URIPATH"
  ]
}
variable "aws_reputation_list" {
  type    = list(string)
  default = [
    "AWSManagedIPReputationList_0000",
    "AWSManagedIPReputationList_0001",
    "AWSManagedIPReputationList_0002",
    "AWSManagedIPReputationList_0003",
    "AWSManagedIPReputationList_0004",
    "AWSManagedIPReputationList_0005",
    "AWSManagedIPReputationList_0006",
    "AWSManagedIPReputationList_0007",
    "AWSManagedIPReputationList_0008",
    "AWSManagedIPReputationList_0009",
    "AWSManagedIPReputationList_0010",
    "AWSManagedIPReputationList_0011",
    "AWSManagedIPReputationList_0012",
    "AWSManagedIPReputationList_0013",
    "AWSManagedIPReputationList_0014",
    "AWSManagedIPReputationList_0015",
    "AWSManagedIPReputationList_0016",
    "AWSManagedIPReputationList_0017",
    "AWSManagedIPReputationList_0018",
    "AWSManagedIPReputationList_0019",
    "AWSManagedIPReputationList_0020",
    "AWSManagedIPReputationList_0021",
    "AWSManagedIPReputationList_0022",
    "AWSManagedIPReputationList_0023",
    "AWSManagedIPReputationList_0024"
  ]
}

resource "aws_wafv2_web_acl" "aws_waf_acl" {
  name        = "aws-waf-acl"
  description = "Example of a managed rule."
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  //  rule {
  //    name     = "AWS-AWSManagedRulesAmazonIpReputationList"
  //    priority = 0
  //    statement {
  //
  //      managed_rule_group_statement {
  //        name        = "AWSManagedRulesAmazonIpReputationList"
  //        vendor_name = "AWS"
  //        dynamic "excluded_rule" {
  //          for_each = var.aws_reputation_list
  //
  //          content {
  //            name = excluded_rule.value
  //          }
  //        }
  //      }
  //    }
  //    override_action {
  //      none {}
  //    }
  //
  //    visibility_config {
  //      cloudwatch_metrics_enabled = true
  //      metric_name                = "AWS-AWSManagedRulesAmazonIpReputationList"
  //      sampled_requests_enabled   = true
  //    }
  //  }

  rule {
    name     = "RateLimit"
    priority = 0
    statement {
      rate_based_statement {
        limit = 75000
        aggregate_key_type = "IP"
      }
    }
    action {
      block {}
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimit"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
        dynamic "excluded_rule" {
          for_each = var.aws_common_rules_set

          content {
            name = excluded_rule.value
          }
        }

      }
    }
    override_action {
      none {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 2
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }
    override_action {
      none {}
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    sampled_requests_enabled   = true
    metric_name                = "aws-waf-acl"
  }
}
