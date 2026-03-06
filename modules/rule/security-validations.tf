# Security Controls Validations
# Enforces security standards based on metadata module security controls

locals {
  # Use security controls if provided, otherwise use permissive defaults
  security_controls = var.security_controls != null ? var.security_controls : {
    encryption = {
      require_kms_customer_managed  = false
      require_encryption_at_rest    = false
      require_encryption_in_transit = false
      enable_kms_key_rotation       = false
    }
    logging = {
      require_cloudwatch_logs = false
      min_log_retention_days  = 1
      require_access_logging  = false
      require_flow_logs       = false
    }
    monitoring = {
      enable_xray_tracing         = false
      enable_enhanced_monitoring  = false
      enable_performance_insights = false
      require_cloudtrail          = false
    }
    iam = {
      require_least_privilege_policies = false
      prohibit_wildcard_resources      = false
      require_mfa_for_humans           = false
      require_service_roles            = false
    }
  }

  # Apply overrides to security controls
  cloudtrail_required = local.security_controls.monitoring.require_cloudtrail && !var.security_control_overrides.disable_cloudtrail

  # Check if targets have retry policies configured
  step_functions_have_retry = alltrue([
    for target in var.step_functions_targets : target.retry_policy != null || var.security_control_overrides.disable_retry_policy
  ])

  lambda_have_retry = alltrue([
    for target in var.lambda_targets : target.retry_policy != null || var.security_control_overrides.disable_retry_policy
  ])

  retry_validation_passed = (
    length(var.step_functions_targets) == 0 || local.step_functions_have_retry
    ) && (
    length(var.lambda_targets) == 0 || local.lambda_have_retry
  )

  # Check if targets have dead letter queues configured
  step_functions_have_dlq = alltrue([
    for target in var.step_functions_targets : target.dead_letter_arn != null || var.security_control_overrides.disable_dead_letter_queue
  ])

  lambda_have_dlq = alltrue([
    for target in var.lambda_targets : target.dead_letter_arn != null || var.security_control_overrides.disable_dead_letter_queue
  ])

  dlq_validation_passed = (
    length(var.step_functions_targets) == 0 || local.step_functions_have_dlq
    ) && (
    length(var.lambda_targets) == 0 || local.lambda_have_dlq
  )

  # Audit trail for overrides
  has_overrides = (
    var.security_control_overrides.disable_dead_letter_queue ||
    var.security_control_overrides.disable_retry_policy ||
    (var.security_control_overrides.disable_cloudtrail && local.cloudtrail_required)
  )

  justification_provided = var.security_control_overrides.justification != ""
  override_audit_passed  = !local.has_overrides || local.justification_provided
}

# Security Controls Check Block
check "security_controls_compliance" {
  assert {
    condition     = local.retry_validation_passed
    error_message = "Security control violation: Retry policies are recommended for all targets but not configured. Set retry_policy for targets or set security_control_overrides.disable_retry_policy=true with justification."
  }

  assert {
    condition     = local.dlq_validation_passed
    error_message = "Security control violation: Dead letter queues are recommended for all targets but not configured. Set dead_letter_arn for targets or set security_control_overrides.disable_dead_letter_queue=true with justification."
  }

  assert {
    condition     = local.override_audit_passed
    error_message = "Security control overrides detected but no justification provided. Please document the business reason in security_control_overrides.justification for audit compliance."
  }
}

# Validation: event_pattern and schedule_expression are mutually exclusive
check "rule_configuration_validation" {
  assert {
    condition     = (var.event_pattern != null && var.schedule_expression == null) || (var.event_pattern == null && var.schedule_expression != null)
    error_message = "Either event_pattern or schedule_expression must be provided, but not both."
  }
}

# Validation: role_arn required if create_role is false
check "iam_role_validation" {
  assert {
    condition     = var.create_role || var.role_arn != null
    error_message = "role_arn must be provided when create_role is false."
  }
}
