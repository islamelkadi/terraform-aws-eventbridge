# EventBridge Rule Module

Creates AWS EventBridge rules with targets for event-driven architectures. Supports Step Functions, Lambda, SNS, and SQS targets with automatic IAM role creation.

## Features

- Event pattern or schedule expression rules
- Multiple target types (Step Functions, Lambda, SNS, SQS)
- Automatic IAM role creation with least privilege
- Input transformation for targets
- Retry policies and dead letter queues
- Security controls integration
- Consistent naming via metadata module

## Security

### Security Controls

This module enforces security best practices:

- **IAM Least Privilege**: Automatic role creation with minimal permissions
- **Retry Policies**: Recommended for all targets to handle transient failures
- **Dead Letter Queues**: Recommended for failed event handling
- **CloudTrail**: Account-level logging for audit compliance

### Security Control Overrides

Use `security_control_overrides` to disable specific controls with justification:

```hcl
security_control_overrides = {
  disable_retry_policy      = true
  disable_dead_letter_queue = true
  justification             = "Low-priority events, acceptable data loss for cost optimization"
}
```

### Environment-Based Security Controls

Security controls are automatically applied based on the environment through the [terraform-aws-metadata](https://github.com/islamelkadi/terraform-aws-metadata?tab=readme-ov-file#security-profiles) module's security profiles:

| Control | Dev | Staging | Prod |
|---------|-----|---------|------|
| IAM least privilege | Enforced | Enforced | Enforced |
| Dead letter queue | Optional | Recommended | Required |
| Retry policies | Optional | Recommended | Required |
| CloudTrail logging | Optional | Required | Required |

For full details on security profiles and how controls vary by environment, see the [Security Profiles](https://github.com/islamelkadi/terraform-aws-metadata?tab=readme-ov-file#security-profiles) documentation.
## Usage

### Basic Example - S3 Event to Step Functions

```hcl
module "s3_event_rule" {
  source = "github.com/islamelkadi/terraform-aws-eventbridge//modules/rule"

  namespace   = "example"
  environment = "dev"
  name        = "s3-upload-trigger"
  region      = "us-east-1"

  description = "Trigger Step Functions on S3 upload"

  # S3 event pattern
  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail-type = ["Object Created"]
    detail = {
      bucket = {
        name = ["my-bucket"]
      }
      object = {
        key = [{
          suffix = ".csv"
        }]
      }
    }
  })

  # Step Functions target
  step_functions_targets = [{
    target_id         = "corporate-actions-workflow"
    state_machine_arn = aws_sfn_state_machine.workflow.arn
    
    input_transformer = {
      input_paths = {
        bucket = "$.detail.bucket.name"
        key    = "$.detail.object.key"
      }
      input_template = <<-EOT
        {
          "s3_bucket": <bucket>,
          "s3_key": <key>,
          "feed_source": "TMX",
          "feed_format": "CSV"
        }
      EOT
    }

    retry_policy = {
      maximum_event_age      = 86400  # 24 hours
      maximum_retry_attempts = 2
    }

    dead_letter_arn = aws_sqs_queue.dlq.arn
  }]

  tags = {
    Application = "corporate-actions"
  }
}
```

### Scheduled Rule Example

```hcl
module "daily_batch_rule" {
  source = "github.com/islamelkadi/terraform-aws-eventbridge//modules/rule"

  namespace   = "example"
  environment = "prod"
  name        = "daily-batch-processor"
  region      = "us-east-1"

  description = "Run daily batch processing at 2 AM UTC"

  # Cron schedule
  schedule_expression = "cron(0 2 * * ? *)"

  # Lambda target
  lambda_targets = [{
    target_id    = "batch-processor"
    function_arn = aws_lambda_function.batch.arn

    retry_policy = {
      maximum_event_age      = 3600  # 1 hour
      maximum_retry_attempts = 3
    }
  }]

  tags = {
    Application = "batch-processing"
  }
}
```

### Multiple Targets Example

```hcl
module "multi_target_rule" {
  source = "github.com/islamelkadi/terraform-aws-eventbridge//modules/rule"

  namespace   = "example"
  environment = "dev"
  name        = "order-processing"
  region      = "us-east-1"

  event_pattern = jsonencode({
    source      = ["custom.orders"]
    detail-type = ["Order Placed"]
  })

  # Step Functions for orchestration
  step_functions_targets = [{
    target_id         = "order-workflow"
    state_machine_arn = aws_sfn_state_machine.orders.arn
  }]

  # SNS for notifications
  sns_targets = [{
    target_id = "order-notifications"
    topic_arn = aws_sns_topic.orders.arn
  }]

  # SQS for async processing
  sqs_targets = [{
    target_id = "order-queue"
    queue_arn = aws_sqs_queue.orders.arn
  }]

  tags = {
    Application = "order-processing"
  }
}
```

## Event Pattern Examples

### S3 Events

```json
{
  "source": ["aws.s3"],
  "detail-type": ["Object Created"],
  "detail": {
    "bucket": {
      "name": ["my-bucket"]
    },
    "object": {
      "key": [{"suffix": ".csv"}]
    }
  }
}
```

### DynamoDB Streams

```json
{
  "source": ["aws.dynamodb"],
  "detail-type": ["DynamoDB Stream Record"],
  "detail": {
    "eventName": ["INSERT", "MODIFY"]
  }
}
```

### Custom Events

```json
{
  "source": ["custom.application"],
  "detail-type": ["Order Placed"],
  "detail": {
    "status": ["pending"]
  }
}
```

## Schedule Expression Examples

### Cron Expressions

- `cron(0 2 * * ? *)` - Daily at 2 AM UTC
- `cron(0 */6 * * ? *)` - Every 6 hours
- `cron(0 9 ? * MON-FRI *)` - Weekdays at 9 AM UTC

### Rate Expressions

- `rate(5 minutes)` - Every 5 minutes
- `rate(1 hour)` - Every hour
- `rate(1 day)` - Daily

<!-- BEGIN_TF_DOCS -->


## Usage

```hcl
terraform {
  required_version = ">= 1.0"
}

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
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.34 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.34 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_metadata"></a> [metadata](#module\_metadata) | github.com/islamelkadi/terraform-aws-metadata | v1.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.sqs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.step_functions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_role.eventbridge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.invoke_targets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_policy_document.eventbridge_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.invoke_targets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_role"></a> [create\_role](#input\_create\_role) | Whether to create an IAM role for EventBridge to invoke targets | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the EventBridge rule | `string` | `""` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Whether the rule is enabled | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, staging, prod) | `string` | n/a | yes |
| <a name="input_event_pattern"></a> [event\_pattern](#input\_event\_pattern) | Event pattern as JSON string. Mutually exclusive with schedule\_expression | `string` | `null` | no |
| <a name="input_lambda_targets"></a> [lambda\_targets](#input\_lambda\_targets) | List of Lambda functions to invoke | <pre>list(object({<br/>    target_id    = string<br/>    function_arn = string<br/>    input_transformer = optional(object({<br/>      input_paths    = map(string)<br/>      input_template = string<br/>    }))<br/>    retry_policy = optional(object({<br/>      maximum_event_age      = optional(number, 86400)<br/>      maximum_retry_attempts = optional(number, 2)<br/>    }))<br/>    dead_letter_arn = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the EventBridge rule | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace (organization/team name) | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region where resources will be created | `string` | n/a | yes |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | ARN of existing IAM role for EventBridge. Required if create\_role is false | `string` | `null` | no |
| <a name="input_schedule_expression"></a> [schedule\_expression](#input\_schedule\_expression) | Schedule expression (rate or cron). Mutually exclusive with event\_pattern | `string` | `null` | no |
| <a name="input_security_control_overrides"></a> [security\_control\_overrides](#input\_security\_control\_overrides) | Override specific security controls for this EventBridge rule.<br/>Only use when there's a documented business justification.<br/><br/>Example use cases:<br/>- disable\_dead\_letter\_queue: Low-priority events (acceptable data loss)<br/>- disable\_retry\_policy: Idempotent operations (no retry needed)<br/><br/>IMPORTANT: Document the reason in the 'justification' field for audit purposes. | <pre>object({<br/>    disable_dead_letter_queue = optional(bool, false)<br/>    disable_retry_policy      = optional(bool, false)<br/>    disable_cloudtrail        = optional(bool, false)<br/><br/>    # Audit trail - document why controls are disabled<br/>    justification = optional(string, "")<br/>  })</pre> | <pre>{<br/>  "disable_cloudtrail": false,<br/>  "disable_dead_letter_queue": false,<br/>  "disable_retry_policy": false,<br/>  "justification": ""<br/>}</pre> | no |
| <a name="input_security_controls"></a> [security\_controls](#input\_security\_controls) | Security controls configuration from metadata module. Used to enforce security standards | <pre>object({<br/>    encryption = object({<br/>      require_kms_customer_managed  = bool<br/>      require_encryption_at_rest    = bool<br/>      require_encryption_in_transit = bool<br/>      enable_kms_key_rotation       = bool<br/>    })<br/>    logging = object({<br/>      require_cloudwatch_logs = bool<br/>      min_log_retention_days  = number<br/>      require_access_logging  = bool<br/>      require_flow_logs       = bool<br/>    })<br/>    monitoring = object({<br/>      enable_xray_tracing         = bool<br/>      enable_enhanced_monitoring  = bool<br/>      enable_performance_insights = bool<br/>      require_cloudtrail          = bool<br/>    })<br/>    iam = object({<br/>      require_least_privilege_policies = bool<br/>      prohibit_wildcard_resources      = bool<br/>      require_mfa_for_humans           = bool<br/>      require_service_roles            = bool<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_sns_targets"></a> [sns\_targets](#input\_sns\_targets) | List of SNS topics to publish to | <pre>list(object({<br/>    target_id = string<br/>    topic_arn = string<br/>  }))</pre> | `[]` | no |
| <a name="input_sqs_targets"></a> [sqs\_targets](#input\_sqs\_targets) | List of SQS queues to send messages to | <pre>list(object({<br/>    target_id = string<br/>    queue_arn = string<br/>  }))</pre> | `[]` | no |
| <a name="input_step_functions_targets"></a> [step\_functions\_targets](#input\_step\_functions\_targets) | List of Step Functions state machines to invoke | <pre>list(object({<br/>    target_id         = string<br/>    state_machine_arn = string<br/>    input_transformer = optional(object({<br/>      input_paths    = map(string)<br/>      input_template = string<br/>    }))<br/>    retry_policy = optional(object({<br/>      maximum_event_age      = optional(number, 86400) # 24 hours<br/>      maximum_retry_attempts = optional(number, 2)<br/>    }))<br/>    dead_letter_arn = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | ARN of the IAM role for EventBridge (if created) |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | Name of the IAM role for EventBridge (if created) |
| <a name="output_rule_arn"></a> [rule\_arn](#output\_rule\_arn) | ARN of the EventBridge rule |
| <a name="output_rule_id"></a> [rule\_id](#output\_rule\_id) | ID of the EventBridge rule |
| <a name="output_rule_name"></a> [rule\_name](#output\_rule\_name) | Name of the EventBridge rule |
| <a name="output_tags"></a> [tags](#output\_tags) | Tags applied to the EventBridge rule |

## Example

See [example/](example/) for a complete working example with all features.

## License

MIT Licensed. See [LICENSE](LICENSE) for full details.
<!-- END_TF_DOCS -->
