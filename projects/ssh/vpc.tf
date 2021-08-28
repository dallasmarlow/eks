# SSH Security Groups

locals {
  security_groups = {
    "external" = {
      "networks" = [var.remote_network]
      "self"     = false
    }
    "internal" = {
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
    self        = each.value.self
  }

  name_prefix            = "${var.eks_cluster_name}-${each.key}-ssh-"
  revoke_rules_on_delete = true
  vpc_id                 = data.terraform_remote_state.vpc.outputs.vpc_id

  tags = {
    Name = "${var.eks_cluster_name}-${each.key}-ssh"
  }
}
