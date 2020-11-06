resource "aws_security_group" "eks_cluster" {
	name = "${var.eks_cluster_name}-cluster"
	vpc_id = data.terraform_remote_state.vpc.outputs.eks_test_vpc_id
	ingress {
		from_port = 443
		protocol = "tcp"
		self = true
		to_port = 443
	}
	egress {
		from_port = 443
		protocol = "tcp"
		self = true
		to_port = 443
	}
	egress {
		from_port = 1025
		protocol = "tcp"
		self = true
		to_port = 65535
	}
	tags = {
		Name = "${var.eks_cluster_name}-cluster"
	}
}