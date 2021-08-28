resource "aws_kms_key" "bastion_ebs" {
  description = "KMS key to be used with bastion EBS volumes."
}