# EventBridge Rule Module
# Creates AWS EventBridge rule with targets and IAM role for invocation

# EventBridge Rule
resource "aws_cloudwatch_event_rule" "this" {
  name        = local.rule_name
  description = var.description != "" ? var.description : "EventBridge rule ${local.rule_name}"

  event_pattern       = var.event_pattern
  schedule_expression = var.schedule_expression

  state = var.enabled ? "ENABLED" : "DISABLED"

  tags = local.tags
}

# IAM Role for EventBridge to invoke targets
resource "aws_iam_role" "eventbridge" {
  count = var.create_role ? 1 : 0

  name               = "${local.rule_name}-role"
  description        = "IAM role for EventBridge rule ${local.rule_name}"
  assume_role_policy = data.aws_iam_policy_document.eventbridge_assume_role[0].json

  tags = local.tags
}

resource "aws_iam_role_policy" "invoke_targets" {
  count = var.create_role ? 1 : 0

  name   = "${local.rule_name}-invoke-targets"
  role   = aws_iam_role.eventbridge[0].id
  policy = data.aws_iam_policy_document.invoke_targets[0].json
}

# Assume role policy for EventBridge
data "aws_iam_policy_document" "eventbridge_assume_role" {
  count = var.create_role ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Policy to invoke targets
data "aws_iam_policy_document" "invoke_targets" {
  count = var.create_role ? 1 : 0

  # Step Functions permissions
  dynamic "statement" {
    for_each = length(var.step_functions_targets) > 0 ? [1] : []
    content {
      effect = "Allow"
      actions = [
        "states:StartExecution"
      ]
      resources = [for target in var.step_functions_targets : target.state_machine_arn]
    }
  }

  # Lambda permissions
  dynamic "statement" {
    for_each = length(var.lambda_targets) > 0 ? [1] : []
    content {
      effect = "Allow"
      actions = [
        "lambda:InvokeFunction"
      ]
      resources = [for target in var.lambda_targets : target.function_arn]
    }
  }

  # SNS permissions
  dynamic "statement" {
    for_each = length(var.sns_targets) > 0 ? [1] : []
    content {
      effect = "Allow"
      actions = [
        "sns:Publish"
      ]
      resources = [for target in var.sns_targets : target.topic_arn]
    }
  }

  # SQS permissions
  dynamic "statement" {
    for_each = length(var.sqs_targets) > 0 ? [1] : []
    content {
      effect = "Allow"
      actions = [
        "sqs:SendMessage"
      ]
      resources = [for target in var.sqs_targets : target.queue_arn]
    }
  }
}

# EventBridge Targets - Step Functions
resource "aws_cloudwatch_event_target" "step_functions" {
  count = length(var.step_functions_targets)

  rule      = aws_cloudwatch_event_rule.this.name
  target_id = var.step_functions_targets[count.index].target_id
  arn       = var.step_functions_targets[count.index].state_machine_arn
  role_arn  = var.create_role ? aws_iam_role.eventbridge[0].arn : var.role_arn

  dynamic "input_transformer" {
    for_each = var.step_functions_targets[count.index].input_transformer != null ? [var.step_functions_targets[count.index].input_transformer] : []
    content {
      input_paths    = input_transformer.value.input_paths
      input_template = input_transformer.value.input_template
    }
  }

  dynamic "retry_policy" {
    for_each = var.step_functions_targets[count.index].retry_policy != null ? [var.step_functions_targets[count.index].retry_policy] : []
    content {
      maximum_event_age_in_seconds = retry_policy.value.maximum_event_age
      maximum_retry_attempts       = retry_policy.value.maximum_retry_attempts
    }
  }

  dynamic "dead_letter_config" {
    for_each = var.step_functions_targets[count.index].dead_letter_arn != null ? [1] : []
    content {
      arn = var.step_functions_targets[count.index].dead_letter_arn
    }
  }
}

# EventBridge Targets - Lambda
resource "aws_cloudwatch_event_target" "lambda" {
  count = length(var.lambda_targets)

  rule      = aws_cloudwatch_event_rule.this.name
  target_id = var.lambda_targets[count.index].target_id
  arn       = var.lambda_targets[count.index].function_arn

  dynamic "input_transformer" {
    for_each = var.lambda_targets[count.index].input_transformer != null ? [var.lambda_targets[count.index].input_transformer] : []
    content {
      input_paths    = input_transformer.value.input_paths
      input_template = input_transformer.value.input_template
    }
  }

  dynamic "retry_policy" {
    for_each = var.lambda_targets[count.index].retry_policy != null ? [var.lambda_targets[count.index].retry_policy] : []
    content {
      maximum_event_age_in_seconds = retry_policy.value.maximum_event_age
      maximum_retry_attempts       = retry_policy.value.maximum_retry_attempts
    }
  }

  dynamic "dead_letter_config" {
    for_each = var.lambda_targets[count.index].dead_letter_arn != null ? [1] : []
    content {
      arn = var.lambda_targets[count.index].dead_letter_arn
    }
  }
}

# EventBridge Targets - SNS
resource "aws_cloudwatch_event_target" "sns" {
  count = length(var.sns_targets)

  rule      = aws_cloudwatch_event_rule.this.name
  target_id = var.sns_targets[count.index].target_id
  arn       = var.sns_targets[count.index].topic_arn
}

# EventBridge Targets - SQS
resource "aws_cloudwatch_event_target" "sqs" {
  count = length(var.sqs_targets)

  rule      = aws_cloudwatch_event_rule.this.name
  target_id = var.sqs_targets[count.index].target_id
  arn       = var.sqs_targets[count.index].queue_arn
}
