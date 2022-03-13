data "aws_iam_policy" "lambda_execution" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy" "lambda_vpc_exection" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
  }
}

# eks_cert_fingerprint_indexer

data "aws_iam_policy_document" "fingerprint_indexer" {
  statement {
    actions = [
      "eks:DescribeCluster",
      "eks:ListClusters",
    ]
    resources = [
      "*",
    ]
    sid = "EksReadOnly"
  }

  statement {
    actions = [
      "ssm:GetParameter",
      "ssm:PutParameter",
    ]
    resources = [
      "arn:aws:ssm:${var.region}:${var.account_id}:parameter/eks_cluster_oidc_fingerprints/*",
    ]
    sid = "SsmReadWrite"
  }
}

resource "aws_iam_policy" "fingerprint_indexer" {
  name   = local.fingerprint_indexer_name
  policy = data.aws_iam_policy_document.fingerprint_indexer.json
}

resource "aws_iam_role" "fingerprint_indexer" {
  name               = local.fingerprint_indexer_name
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "fingerprint_indexer" {
  role       = aws_iam_role.fingerprint_indexer.name
  policy_arn = aws_iam_policy.fingerprint_indexer.arn
}

resource "aws_iam_role_policy_attachment" "fingerprint_indexer_exec" {
  role       = aws_iam_role.fingerprint_indexer.name
  policy_arn = data.aws_iam_policy.lambda_vpc_exection.arn
}
