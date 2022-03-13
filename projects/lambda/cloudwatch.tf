resource "aws_cloudwatch_log_group" "log_group" {
  for_each = toset([
    local.fingerprint_indexer_name,
  ])

  name              = "/aws/lambda/${each.key}"
  retention_in_days = var.cloudwatch_log_group_retention_in_days
}