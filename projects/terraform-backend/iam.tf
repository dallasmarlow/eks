data "aws_iam_policy_document" "terraform_dynamodb_locktable" {
  statement {
    actions = [
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
    ]
    resources = [
      aws_dynamodb_table.terraform_state_lock.arn
    ]
  }
}

data "aws_iam_policy_document" "terraform_s3_backend" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
    ]
    resources = [
      aws_s3_bucket.terraform-backend.arn,
      "${aws_s3_bucket.terraform-backend.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "terraform_dynamodb_locktable" {
  name_prefix = "terraform-dynamodb-locktable"
  policy      = data.aws_iam_policy_document.terraform_dynamodb_locktable.json
}

resource "aws_iam_policy" "terraform_s3_backend" {
  name_prefix = "terraform-s3-backend"
  policy      = data.aws_iam_policy_document.terraform_s3_backend.json
}