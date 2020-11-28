resource "aws_s3_bucket" "terraform-backend" {
	bucket = "eks-test-tf-backend"
	acl = "private"
	force_destroy = true
	server_side_encryption_configuration {
		rule {
			apply_server_side_encryption_by_default {
				sse_algorithm = "AES256"
			}
		}
	}

	# use versioning for production / long term use-cases, but disable
	# for ephemeral deployments to allow `terraform destroy` to delete the bucket automatically.
	# versioning {
	# 	enabled = true
	# }
}

resource "aws_s3_bucket_public_access_block" "terraform-backend" {
	bucket = aws_s3_bucket.terraform-backend.id
	block_public_acls = true
	block_public_policy = true
	ignore_public_acls = true
	restrict_public_buckets = true
}