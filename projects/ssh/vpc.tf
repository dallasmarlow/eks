# SSH Security Groups

locals {
  security_groups = {
    "external" = {
      "ipv6_networks" = data.aws_ip_ranges.ec2_instance_connect.ipv6_cidr_blocks
      "networks" = concat(
        data.aws_ip_ranges.ec2_instance_connect.cidr_blocks,
        [var.remote_network])
      "self"     = false
    }
    "internal" = {
      "ipv6_networks" = []
      "networks" = []
      "self"     = true
    }
  }
}

resource "aws_security_group" "ssh" {
  for_each = local.security_groups

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = each.value.networks
    ipv6_cidr_blocks = each.value.ipv6_networks
    self        = each.value.self
  }

  name_prefix            = "${var.eks_cluster_name}-${each.key}-ssh-"
  revoke_rules_on_delete = true
  vpc_id                 = data.terraform_remote_state.vpc.outputs.vpc_id

  tags = {
    Name = "${var.eks_cluster_name}-${each.key}-ssh"
  }
}
