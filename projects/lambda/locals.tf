locals {
  fingerprint_indexer_dist_path = "${path.module}/../../dist/eks_cert_fingerprint_indexer"
  fingerprint_indexer_name      = "eks-cert-fingerprint-indexer"
  fingerprint_indexer_src_path  = "${path.module}/../../src/eks_cert_fingerprint_indexer"
}