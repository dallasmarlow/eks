resource "aws_s3_bucket" "bastion_utils" {
	bucket = "eks-test-bastion-utils"
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

resource "aws_s3_bucket_object" "ec2_instance_connect_common" {
	bucket = aws_s3_bucket.bastion_utils.id
	content = file("${path.module}/scripts/ec2-instance-connect-common.sh")
	key = "ec2-instance-connect-common.sh"
}

resource "aws_s3_bucket_object" "ec2_instance_connect_send_key" {
	bucket = aws_s3_bucket.bastion_utils.id
	content = file("${path.module}/scripts/ec2-instance-connect-send-key.sh")
	key = "ec2-instance-connect-send-key"
}

resource "aws_s3_bucket_object" "ec2_instance_connect_ssh" {
	bucket = aws_s3_bucket.bastion_utils.id
	content = file("${path.module}/scripts/ec2-instance-connect-ssh.sh")
	key = "ec2-instance-connect-ssh"
}