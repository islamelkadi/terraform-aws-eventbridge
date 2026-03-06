# Basic EventBridge Rule Example

module "eventbridge_rule" {
  source = "../"

  namespace   = var.namespace
  environment = var.environment
  name        = var.name
  region      = var.region

  description         = var.description
  schedule_expression = var.schedule_expression
  enabled             = var.enabled

  step_functions_targets = [{
    target_id         = "daily-processor-sfn"
    state_machine_arn = var.state_machine_arn

    input_transformer = {
      input_paths = {
        time = "$.time"
      }
      input_template = <<-EOT
        {
          "execution_time": <time>,
          "job_type": "daily_processing"
        }
      EOT
    }

    retry_policy = {
      maximum_event_age      = 86400
      maximum_retry_attempts = 2
    }

    dead_letter_arn = var.dead_letter_arn
  }]

  tags = var.tags
}
