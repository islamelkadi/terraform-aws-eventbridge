variable "namespace" {
  description = "Namespace (organization/team name)"
  type        = string
  default     = "example"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "name" {
  description = "Name for the EventBridge rule"
  type        = string
  default     = "daily-processor"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "description" {
  description = "Description of the EventBridge rule"
  type        = string
  default     = "Daily processing job triggered at 2 AM UTC"
}

variable "schedule_expression" {
  description = "Schedule expression for the rule"
  type        = string
  default     = "cron(0 2 * * ? *)"
}

variable "enabled" {
  description = "Whether the rule is enabled"
  type        = bool
  default     = true
}

variable "state_machine_arn" {
  description = "ARN of the Step Functions state machine target"
  type        = string
  default     = "arn:aws:states:us-east-1:123456789012:stateMachine:daily-processor"
}

variable "dead_letter_arn" {
  description = "ARN of the SQS dead letter queue"
  type        = string
  default     = "arn:aws:sqs:us-east-1:123456789012:eventbridge-dlq"
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default = {
    Example = "EVENTBRIDGE_RULE"
    Purpose = "DAILY_PROCESSING"
  }
}
