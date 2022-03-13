resource "aws_cloudwatch_log_group" "log_group" {
  for_each = local.lambda_cloudwatch_log_groups

  name              = "/aws/lambda/${each.key}"
  retention_in_days = var.cloudwatch_log_group_retention_in_days
}