# Outputs for EventBridge Rule example

output "rule_id" {
  description = "EventBridge rule ID"
  value       = module.eventbridge_rule.rule_id
}

output "rule_arn" {
  description = "EventBridge rule ARN"
  value       = module.eventbridge_rule.rule_arn
}

output "rule_name" {
  description = "EventBridge rule name"
  value       = module.eventbridge_rule.rule_name
}

output "role_arn" {
  description = "IAM role ARN"
  value       = module.eventbridge_rule.role_arn
}
