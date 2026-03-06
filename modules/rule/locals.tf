# Local values for EventBridge Rule module

locals {
  # Get rule name from metadata module
  rule_name = module.metadata.resource_prefix

  # Merge tags with defaults
  tags = merge(
    var.tags,
    module.metadata.security_tags,
    {
      Name   = module.metadata.resource_prefix
      Module = "terraform-aws-eventbridge-rule"
    }
  )
}
