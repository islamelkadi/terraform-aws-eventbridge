# EventBridge Rule Module Outputs

output "rule_id" {
  description = "ID of the EventBridge rule"
  value       = aws_cloudwatch_event_rule.this.id
}

output "rule_arn" {
  description = "ARN of the EventBridge rule"
  value       = aws_cloudwatch_event_rule.this.arn
}

output "rule_name" {
  description = "Name of the EventBridge rule"
  value       = aws_cloudwatch_event_rule.this.name
}

output "role_arn" {
  description = "ARN of the IAM role for EventBridge (if created)"
  value       = var.create_role ? aws_iam_role.eventbridge[0].arn : var.role_arn
}

output "role_name" {
  description = "Name of the IAM role for EventBridge (if created)"
  value       = var.create_role ? aws_iam_role.eventbridge[0].name : null
}

output "tags" {
  description = "Tags applied to the EventBridge rule"
  value       = aws_cloudwatch_event_rule.this.tags
}
