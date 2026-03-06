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
