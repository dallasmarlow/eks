resource "aws_s3_bucket" "lb_logs" {
	bucket = "${var.eks_cluster_name}-lb-logs"
	acl = "private"
	force_destroy = true
	server_side_encryption_configuration {
		rule {
			apply_server_side_encryption_by_default {
				sse_algorithm = "AES256"
			}
		}
	}

	lifecycle_rule {
		abort_incomplete_multipart_upload_days = 1
		id = "expire"
		enabled = true
		expiration {
			days = var.eks_cluster_logs_retention_days
		}
	}

	# use versioning for production / long term use-cases, but disable
	# for ephemeral deployments to allow `terraform destroy` to delete the bucket automatically.
	# versioning {
	# 	enabled = true
	# }
}

data "aws_iam_policy_document" "lb_logs_bucket_policy" {
	statement {
		actions = [
			"s3:PutObject",
		]
		principals {
			type = "AWS"
			identifiers = [
				"arn:aws:iam::${var.elb_account_ids[var.region]}:root",
			]
		}
		resources = [
			"${aws_s3_bucket.lb_logs.arn}/*",
		]
	}
	statement {
		actions = [
			"s3:PutObject",
		]
		condition {
			test = "StringEquals"
			variable = "s3:x-amz-acl"
			values = [
				"bucket-owner-full-control",
			]
		}
		principals {
			type = "Service"
			identifiers = [
				"delivery.logs.amazonaws.com",
			]
		}
		resources = [
			"${aws_s3_bucket.lb_logs.arn}/*",
		]
	}
	statement {
		actions = [
			"s3:GetBucketAcl",
		]
		principals {
			type = "Service"
			identifiers = [
				"delivery.logs.amazonaws.com",
			]
		}
		resources = [
			aws_s3_bucket.lb_logs.arn,
		]
	}
}

resource "aws_s3_bucket_policy" "lb_logs" {
	bucket = aws_s3_bucket.lb_logs.id
	policy = data.aws_iam_policy_document.lb_logs_bucket_policy.json
	depends_on = [
		aws_s3_bucket_public_access_block.lb_logs,
	]
}

resource "aws_s3_bucket_public_access_block" "lb_logs" {
	bucket = aws_s3_bucket.lb_logs.id
	block_public_acls = true
	block_public_policy = true
	ignore_public_acls = true
	restrict_public_buckets = true
}