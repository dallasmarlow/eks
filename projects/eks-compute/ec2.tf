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
		name = aws_iam_instance_profile.eks_worker.name
	}
	instance_type = var.eks_worker_instance_type
	key_name = var.ssh_key
	monitoring {
		enabled = true
	}
	vpc_security_group_ids = [aws_security_group.eks_worker.id]
	tag_specifications {
		resource_type = "instance"
		tags = {
			Name = "${aws_eks_cluster.eks_cluster.name}-eks-worker"
			"kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
		}
	}
	update_default_version = true
	user_data = base64encode(templatefile(
		"../../templates/eks_worker_bootstrap.sh.tpl",
		{
			CLUSTER_NAME = aws_eks_cluster.eks_cluster.name,
			B64_CLUSTER_CA = aws_eks_cluster.eks_cluster.certificate_authority[0].data,
			API_SERVER_URL = aws_eks_cluster.eks_cluster.endpoint,
			KUBECTL_URL = var.kubectl_url,
		}))
	depends_on = [
		aws_iam_instance_profile.eks_worker,
		aws_kms_key.eks_worker_ebs,
		aws_security_group.eks_worker,
	]
	lifecycle {
		create_before_destroy = true
	}
}

resource "aws_autoscaling_group" "eks_worker" {
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
	name_prefix = "${aws_eks_cluster.eks_cluster.name}-eks-worker-"
	max_size = 1
	min_size = 1
	launch_template {
		id = aws_launch_template.eks_worker.id
		version = aws_launch_template.eks_worker.latest_version
	}
	vpc_zone_identifier  = [
		data.terraform_remote_state.vpc.outputs.eks_test_priv_subnet_a,
		data.terraform_remote_state.vpc.outputs.eks_test_priv_subnet_b,
	]
	termination_policies = ["OldestInstance"]
	depends_on = [
		aws_kms_grant.eks_worker_ebs_asg,
        ]
}
