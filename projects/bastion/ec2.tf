locals {
  name = "${data.terraform_remote_state.eks_cluster.outputs.cluster_name}-bastion"
}

data "aws_ssm_parameter" "bastion_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-${var.bastion_arch}-gp2"
}

resource "aws_instance" "bastion" {
  ami                  = data.aws_ssm_parameter.bastion_ami.value
  iam_instance_profile = aws_iam_instance_profile.bastion_instance_profile.name
  instance_type        = var.bastion_instance_type
  key_name             = data.terraform_remote_state.ssh.outputs.ec2_keypair_name
  root_block_device {
    volume_size = var.bastion_ebs_volume_size
    encrypted   = true
    kms_key_id  = aws_kms_key.bastion_ebs.arn
  }
  subnet_id = data.terraform_remote_state.vpc.outputs.public_subnet_ids[0]
  user_data = templatefile(
    "${path.module}/templates/bootstrap.sh.tpl",
    {
      CLUSTER_NAME = data.terraform_remote_state.eks_cluster.outputs.cluster_name,
      HELM_URL     = var.helm_url,
      KUBECTL_URL  = var.kubectl_url,
      S3_BUCKET    = aws_s3_bucket.bastion_utils.id,
  TERRAFORM_URL = var.terraform_url })
  vpc_security_group_ids = [
    aws_security_group.bastion.id,
    data.terraform_remote_state.eks_cluster.outputs.cluster_sg_id,
    data.terraform_remote_state.ssh.outputs.ssh_external_sg_id,
    data.terraform_remote_state.ssh.outputs.ssh_internal_sg_id,
  ]
  tags = {
    Name = local.name
  }
  depends_on = [
    aws_s3_object.ec2_instance_connect_common,
    aws_s3_object.ec2_instance_connect_send_key,
    aws_s3_object.ec2_instance_connect_ssh,
    aws_s3_object.list_eks_admin_token,
  ]
}

resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
  vpc      = true
  tags = {
    Name = local.name
  }
}