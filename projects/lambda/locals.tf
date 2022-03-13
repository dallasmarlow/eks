locals {
  fingerprint_indexer_dist_path = "${path.module}/../../dist/eks_cert_fingerprint_indexer"
  fingerprint_indexer_src_path  = "${path.module}/../../src/eks_cert_fingerprint_indexer"
  lambda_cloudwatch_log_groups  = toset(var.lambda_cloudwatch_log_groups)
}