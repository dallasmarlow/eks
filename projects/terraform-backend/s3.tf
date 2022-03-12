resource "aws_s3_bucket" "terraform_backend" {
  bucket        = "eks-test-tf-backend"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "terraform_backend" {
  acl = "private"
  bucket = aws_s3_bucket.terraform_backend.id
}

resource "aws_s3_bucket_public_access_block" "terraform_backend" {
  bucket                  = aws_s3_bucket.terraform_backend.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_backend" {
  bucket = aws_s3_bucket.terraform_backend.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# use versioning for production / long term use-cases, but disable
# for ephemeral deployments to allow `terraform destroy` to delete the bucket automatically.
resource "aws_s3_bucket_versioning" "terraform_backend" {
  bucket = aws_s3_bucket.terraform_backend.id
  versioning_configuration {
    status = "Suspended"
  }
}