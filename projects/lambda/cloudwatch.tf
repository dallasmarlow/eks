resource "aws_cloudwatch_log_group" "log_group" {
  for_each = toset([
    local.fingerprint_indexer_name,
  ])

  name              = "/aws/lambda/${each.key}"
  retention_in_days = var.cloudwatch_log_group_retention_in_days
}

# eks_cert_fingerprint_indexer

resource "aws_cloudwatch_event_rule" "fingerprint_indexer" {
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "fingerprint_indexer" {
  rule = aws_cloudwatch_event_rule.fingerprint_indexer.name
  arn  = aws_lambda_alias.fingerprint_indexer.arn
}