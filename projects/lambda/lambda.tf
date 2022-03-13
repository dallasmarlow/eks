# eks_cert_fingerprint_indexer

data "archive_file" "fingerprint_indexer" {
  depends_on = [
    null_resource.fingerprint_indexer
  ]

  output_path = "${local.fingerprint_indexer_dist_path}.zip"
  source_file = local.fingerprint_indexer_dist_path
  type        = "zip"
}

resource "aws_lambda_function" "fingerprint_indexer" {
  architectures                  = ["x86_64"] # ["arm64"]
  filename                       = data.archive_file.fingerprint_indexer.output_path
  function_name                  = local.fingerprint_indexer_name
  handler                        = "eks_cert_fingerprint_indexer"
  memory_size                    = 128 # MB
  package_type                   = "Zip"
  reserved_concurrent_executions = 1
  role                           = aws_iam_role.fingerprint_indexer.arn
  runtime                        = "go1.x"
  source_code_hash               = data.archive_file.fingerprint_indexer.output_base64sha256
  timeout                        = 300 # seconds

  vpc_config {
    security_group_ids = [
      data.terraform_remote_state.eks_cluster.outputs.cluster_sg_id,
    ]
    subnet_ids = data.terraform_remote_state.vpc.outputs.primary_subnet_ids
  }
}

resource "null_resource" "fingerprint_indexer" {
  triggers = {
    hash_go_mod = filemd5("${local.fingerprint_indexer_src_path}/go.mod")
    hash_go_sum = filemd5("${local.fingerprint_indexer_src_path}/go.sum")
  }

  provisioner "local-exec" {
    interpreter = [
      "/bin/bash",
      "-c",
    ]
    command = join(" ", [
      "env",
      "GO111MODULE=on",
      "GOARCH=amd64",
      "GOOS=linux",
      "go build",
      "-o ${local.fingerprint_indexer_dist_path}",
      "${local.fingerprint_indexer_src_path}/lambda/*",
    ])
  }
}
