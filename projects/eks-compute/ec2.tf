locals {
  name_prefix = "${data.terraform_remote_state.eks_cluster.outputs.cluster_name}-compute-"
}

data "aws_ssm_parameter" "eks_ami" {
  name = "/aws/service/eks/optimized-ami/${data.terraform_remote_state.eks_cluster.outputs.cluster_version}/amazon-linux-2/recommended/image_id"
}

resource "aws_launch_template" "compute" {
  name_prefix = local.name_prefix
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      delete_on_termination = true
      encrypted             = true
      kms_key_id            = aws_kms_key.compute_ebs.arn
      volume_size           = 40 # GB
      volume_type           = "gp2"
    }
  }
  image_id = data.aws_ssm_parameter.eks_ami.value
  iam_instance_profile {
    name = aws_iam_instance_profile.compute.name
  }
  instance_type = var.eks_compute_instance_type
  key_name      = data.terraform_remote_state.ssh.outputs.ec2_keypair_name
  monitoring {
    enabled = true
  }
  vpc_security_group_ids = [
    aws_security_group.compute.id,
    data.terraform_remote_state.eks_cluster.outputs.cluster_sg_id,
    data.terraform_remote_state.ssh.outputs.ssh_internal_sg_id,
  ]
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name                                                                                    = "${data.terraform_remote_state.eks_cluster.outputs.cluster_name}-compute"
      "kubernetes.io/cluster/${data.terraform_remote_state.eks_cluster.outputs.cluster_name}" = "owned"
    }
  }
  update_default_version = true
  user_data = base64encode(templatefile(
    "${path.module}/templates/bootstrap.sh.tpl",
    {
      API_SERVER_URL   = data.terraform_remote_state.eks_cluster.outputs.cluster_endpoint,
      B64_CLUSTER_CA   = data.terraform_remote_state.eks_cluster.outputs.cluster_ca,
      CLUSTER_NAME     = data.terraform_remote_state.eks_cluster.outputs.cluster_name,
      KUBECTL_URL      = var.kubectl_url,
      KUBELET_MAX_PODS = var.kubelet_max_pods,
  }))
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "compute" {
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
  name_prefix = local.name_prefix
  max_size    = 3
  min_size    = 0
  launch_template {
    id      = aws_launch_template.compute.id
    version = aws_launch_template.compute.latest_version
  }
  vpc_zone_identifier  = data.terraform_remote_state.vpc.outputs.primary_subnet_ids
  termination_policies = ["OldestInstance"]
}
