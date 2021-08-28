output "iam_policy_terraform_dynamodb_locktable_arn" {
  value = aws_iam_policy.terraform_dynamodb_locktable.arn
}

output "iam_policy_terraform_s3_backend_arn" {
  value = aws_iam_policy.terraform_s3_backend.arn
}