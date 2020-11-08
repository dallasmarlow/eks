data "aws_ssm_parameter" "eks_compute_ami" {
	name = "/aws/service/eks/optimized-ami/${data.terraform_remote_state.eks_cluster.outputs.eks_cluster_version}/amazon-linux-2/recommended/image_id"
}

resource "aws_launch_template" "eks_compute" {
	name_prefix = "${var.eks_cluster_name}-compute-"
	block_device_mappings {
		device_name = "/dev/xvda"
		ebs {
			delete_on_termination = true
			encrypted = true
			kms_key_id = aws_kms_key.eks_compute_ebs.arn
			volume_size = 40 # GB
			volume_type = "gp2"
		}
	}
	image_id = data.aws_ssm_parameter.eks_compute_ami.value
	iam_instance_profile {
		name = aws_iam_instance_profile.eks_compute.name
	}
	instance_type = var.eks_compute_instance_type
	key_name = data.terraform_remote_state.ssh.outputs.eks_test_ec2_keypair_name
	monitoring {
		enabled = true
	}
	vpc_security_group_ids = [
		aws_security_group.eks_compute.id,
		data.terraform_remote_state.eks_cluster.outputs.eks_cluster_sg_id,
		data.terraform_remote_state.vpc.outputs.ssh_internal_sg_id,
	]
	tag_specifications {
		resource_type = "instance"
		tags = {
			Name = "${data.terraform_remote_state.eks_cluster.outputs.eks_cluster_name}-eks-compute"
			"kubernetes.io/cluster/${data.terraform_remote_state.eks_cluster.outputs.eks_cluster_name}" = "owned"
		}
	}
	update_default_version = true
	user_data = base64encode(templatefile(
		"../../templates/eks_compute_bootstrap.sh.tpl",
		{
			API_SERVER_URL = data.terraform_remote_state.eks_cluster.outputs.eks_cluster_endpoint,
			B64_CLUSTER_CA = data.terraform_remote_state.eks_cluster.outputs.eks_cluster_ca,
			CLUSTER_NAME = data.terraform_remote_state.eks_cluster.outputs.eks_cluster_name,
			KUBECTL_URL = var.kubectl_url,
		}))
	lifecycle {
		create_before_destroy = true
	}
}

resource "aws_autoscaling_group" "eks_compute" {
	enabled_metrics = [
		"GroupDesiredCapacity",
		"GroupInServiceCapacity",
		"GroupPendingCapacity",
		"GroupMinSize",
		"GroupMaxSize",
		"GroupInServiceInstances",
		"GroupPendingInstances",
		"GroupStandbyInstances",
		"GroupStandbyCapacity",
		"GroupTerminatingCapacity",
		"GroupTerminatingInstances",
		"GroupTotalCapacity",
		"GroupTotalInstances",
	]
	name_prefix = "${data.terraform_remote_state.eks_cluster.outputs.eks_cluster_name}-eks-compute-"
	max_size = 3
	min_size = 0
	launch_template {
		id = aws_launch_template.eks_compute.id
		version = aws_launch_template.eks_compute.latest_version
	}
	vpc_zone_identifier  = [
		data.terraform_remote_state.vpc.outputs.eks_test_priv_subnet_a,
		data.terraform_remote_state.vpc.outputs.eks_test_priv_subnet_b,
	]
	termination_policies = ["OldestInstance"]
	depends_on = [aws_kms_grant.eks_compute_ebs_asg]
}
