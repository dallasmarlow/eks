data "aws_ssm_parameter" "bastion_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_instance" "bastion" {
	ami = data.aws_ssm_parameter.bastion_ami.value
	iam_instance_profile = aws_iam_instance_profile.bastion_instance_profile.name
	instance_type = var.bastion_instance_type
	key_name = var.ssh_key
	root_block_device {
		volume_size = 40 # GB
		encrypted = true
		kms_key_id = aws_kms_key.bastion_ebs.arn
	}
	subnet_id = data.terraform_remote_state.vpc.outputs.eks_test_pub_subnet_a
	user_data = templatefile(
		"../../templates/bastion_bootstrap.sh.tpl",
		{CLUSTER_NAME = var.eks_cluster_name, KUBECTL_URL = var.kubectl_url, TERRAFORM_URL = var.terraform_url})
	vpc_security_group_ids = [
		aws_security_group.bastion.id,
		data.terraform_remote_state.eks_cluster.outputs.eks_cluster_sg_id,
		data.terraform_remote_state.vpc.outputs.ssh_external_sg_id,
		data.terraform_remote_state.vpc.outputs.ssh_internal_sg_id,
	]
	tags = {
		Name = "bastion"
	}
}

resource "aws_eip" "bastion" {
	instance = aws_instance.bastion.id
	vpc = true
	tags = {
		Name = "bastion"
	}
}