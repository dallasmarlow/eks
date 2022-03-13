# eks_cert_fingerprint_indexer
data "archive_file" "fingerprint_indexer" {
  depends_on = [
    null_resource.fingerprint_indexer
  ]

  output_path = "${local.fingerprint_indexer_dist_path}.zip"
  source_file = local.fingerprint_indexer_dist_path
  type        = "zip"
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
      "GOOS=linux",
      "go build",
      "-o ${local.fingerprint_indexer_dist_path}",
      "${local.fingerprint_indexer_src_path}/lambda/*",
    ])
  }
}

