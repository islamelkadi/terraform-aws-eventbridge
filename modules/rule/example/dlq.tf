# Supporting Infrastructure - Real DLQ resources for testing
# This infrastructure is created from remote GitHub modules to provide
# realistic dead letter queue dependencies for the primary module example.
# 
# Available module outputs (reference directly in main.tf):
# - module.dead_letter_queue.queue_arn
# - module.dead_letter_queue.queue_url
#
# Example usage in main.tf:
#   dead_letter_arn = module.dead_letter_queue.queue_arn

module "kms_key" {
  source = "git::https://github.com/islamelkadi/terraform-aws-kms.git?ref=v1.0.0"

  namespace   = var.namespace
  environment = var.environment
  name        = "example-key"
  region      = var.region

  description             = "KMS key for example infrastructure"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Purpose = "example-supporting-infrastructure"
  }
}

module "dead_letter_queue" {
  source = "git::https://github.com/islamelkadi/terraform-aws-sqs.git?ref=v1.0.0"

  namespace   = var.namespace
  environment = var.environment
  name        = "example-dlq"
  region      = var.region

  kms_master_key_id = module.kms_key.key_id

  message_retention_seconds = 1209600 # 14 days

  tags = {
    Purpose = "example-supporting-infrastructure"
  }
}
