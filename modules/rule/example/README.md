# Basic EventBridge Rule Example

This example creates a scheduled EventBridge rule that triggers a Step Functions state machine daily at 2 AM UTC.

## Usage

```bash
terraform init
terraform plan -var-file=params/input.tfvars
terraform apply -var-file=params/input.tfvars
```

## What This Example Creates

- EventBridge rule with cron schedule
- Step Functions target with input transformation and retry policy
- IAM role for EventBridge to invoke the target

## Prerequisites

- Existing Step Functions state machine
- Existing SQS queue for dead letter queue

## Clean Up

```bash
terraform destroy -var-file=params/input.tfvars
```

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_dead_letter_queue"></a> [dead\_letter\_queue](#module\_dead\_letter\_queue) | git::https://github.com/islamelkadi/terraform-aws-sqs.git | v1.0.0 |
| <a name="module_eventbridge_rule"></a> [eventbridge\_rule](#module\_eventbridge\_rule) | ../ | n/a |
| <a name="module_kms_key"></a> [kms\_key](#module\_kms\_key) | git::https://github.com/islamelkadi/terraform-aws-kms.git | v1.0.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dead_letter_arn"></a> [dead\_letter\_arn](#input\_dead\_letter\_arn) | ARN of the SQS dead letter queue | `string` | `"arn:aws:sqs:us-east-1:123456789012:eventbridge-dlq"` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the EventBridge rule | `string` | `"Daily processing job triggered at 2 AM UTC"` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Whether the rule is enabled | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | `"dev"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for the EventBridge rule | `string` | `"daily-processor"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace (organization/team name) | `string` | `"example"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |
| <a name="input_schedule_expression"></a> [schedule\_expression](#input\_schedule\_expression) | Schedule expression for the rule | `string` | `"cron(0 2 * * ? *)"` | no |
| <a name="input_state_machine_arn"></a> [state\_machine\_arn](#input\_state\_machine\_arn) | ARN of the Step Functions state machine target | `string` | `"arn:aws:states:us-east-1:123456789012:stateMachine:daily-processor"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags | `map(string)` | <pre>{<br/>  "Example": "EVENTBRIDGE_RULE",<br/>  "Purpose": "DAILY_PROCESSING"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | IAM role ARN |
| <a name="output_rule_arn"></a> [rule\_arn](#output\_rule\_arn) | EventBridge rule ARN |
| <a name="output_rule_id"></a> [rule\_id](#output\_rule\_id) | EventBridge rule ID |
| <a name="output_rule_name"></a> [rule\_name](#output\_rule\_name) | EventBridge rule name |
<!-- END_TF_DOCS -->
