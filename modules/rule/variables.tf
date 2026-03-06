# EventBridge Rule Module Variables

# Metadata variables for consistent naming
variable "namespace" {
  description = "Namespace (organization/team name)"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod"
  }
}

variable "name" {
  description = "Name of the EventBridge rule"
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "AWS region where resources will be created"
  type        = string
}

# EventBridge Rule Configuration
variable "description" {
  description = "Description of the EventBridge rule"
  type        = string
  default     = ""
}

variable "event_pattern" {
  description = "Event pattern as JSON string. Mutually exclusive with schedule_expression"
  type        = string
  default     = null
}

variable "schedule_expression" {
  description = "Schedule expression (rate or cron). Mutually exclusive with event_pattern"
  type        = string
  default     = null
}

variable "enabled" {
  description = "Whether the rule is enabled"
  type        = bool
  default     = true
}

# IAM Role Configuration
variable "create_role" {
  description = "Whether to create an IAM role for EventBridge to invoke targets"
  type        = bool
  default     = true
}

variable "role_arn" {
  description = "ARN of existing IAM role for EventBridge. Required if create_role is false"
  type        = string
  default     = null
}

# Target Configuration - Step Functions
variable "step_functions_targets" {
  description = "List of Step Functions state machines to invoke"
  type = list(object({
    target_id         = string
    state_machine_arn = string
    input_transformer = optional(object({
      input_paths    = map(string)
      input_template = string
    }))
    retry_policy = optional(object({
      maximum_event_age      = optional(number, 86400) # 24 hours
      maximum_retry_attempts = optional(number, 2)
    }))
    dead_letter_arn = optional(string)
  }))
  default = []
}

# Target Configuration - Lambda
variable "lambda_targets" {
  description = "List of Lambda functions to invoke"
  type = list(object({
    target_id    = string
    function_arn = string
    input_transformer = optional(object({
      input_paths    = map(string)
      input_template = string
    }))
    retry_policy = optional(object({
      maximum_event_age      = optional(number, 86400)
      maximum_retry_attempts = optional(number, 2)
    }))
    dead_letter_arn = optional(string)
  }))
  default = []
}

# Target Configuration - SNS
variable "sns_targets" {
  description = "List of SNS topics to publish to"
  type = list(object({
    target_id = string
    topic_arn = string
  }))
  default = []
}

# Target Configuration - SQS
variable "sqs_targets" {
  description = "List of SQS queues to send messages to"
  type = list(object({
    target_id = string
    queue_arn = string
  }))
  default = []
}

# Security Controls
variable "security_controls" {
  description = "Security controls configuration from metadata module. Used to enforce security standards"
  type = object({
    encryption = object({
      require_kms_customer_managed  = bool
      require_encryption_at_rest    = bool
      require_encryption_in_transit = bool
      enable_kms_key_rotation       = bool
    })
    logging = object({
      require_cloudwatch_logs = bool
      min_log_retention_days  = number
      require_access_logging  = bool
      require_flow_logs       = bool
    })
    monitoring = object({
      enable_xray_tracing         = bool
      enable_enhanced_monitoring  = bool
      enable_performance_insights = bool
      require_cloudtrail          = bool
    })
    iam = object({
      require_least_privilege_policies = bool
      prohibit_wildcard_resources      = bool
      require_mfa_for_humans           = bool
      require_service_roles            = bool
    })
  })
  default = null
}

# Security Control Overrides
variable "security_control_overrides" {
  description = <<-EOT
    Override specific security controls for this EventBridge rule.
    Only use when there's a documented business justification.
    
    Example use cases:
    - disable_dead_letter_queue: Low-priority events (acceptable data loss)
    - disable_retry_policy: Idempotent operations (no retry needed)
    
    IMPORTANT: Document the reason in the 'justification' field for audit purposes.
  EOT

  type = object({
    disable_dead_letter_queue = optional(bool, false)
    disable_retry_policy      = optional(bool, false)
    disable_cloudtrail        = optional(bool, false)

    # Audit trail - document why controls are disabled
    justification = optional(string, "")
  })

  default = {
    disable_dead_letter_queue = false
    disable_retry_policy      = false
    disable_cloudtrail        = false
    justification             = ""
  }
}
