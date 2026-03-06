namespace   = "example"
environment = "dev"
name        = "daily-processor"
region      = "us-east-1"

description         = "Daily processing job triggered at 2 AM UTC"
schedule_expression = "cron(0 2 * * ? *)"
enabled             = true

state_machine_arn = "arn:aws:states:us-east-1:123456789012:stateMachine:daily-processor"
dead_letter_arn   = "arn:aws:sqs:us-east-1:123456789012:eventbridge-dlq"

tags = {
  Example = "EVENTBRIDGE_RULE"
  Purpose = "DAILY_PROCESSING"
}
