# Primary Module Example - This demonstrates the terraform-aws-eventbridge rule module
# Supporting infrastructure (DLQ) is defined in separate files
# to keep this example focused on the module's core functionality.
#
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

    # Direct reference to dlq.tf module output
    dead_letter_arn = module.dead_letter_queue.queue_arn
  }]

  tags = var.tags
}
