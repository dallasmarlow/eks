resource "aws_security_group" "eks_compute" {
	name_prefix = "${var.eks_cluster_name}-eks-compute"
	vpc_id = data.terraform_remote_state.vpc.outputs.eks_test_vpc_id
	tags = {
		Name = "${var.eks_cluster_name}-eks-compute"
	}
}

resource "aws_security_group_rule" "eks_compute_egress" {
	cidr_blocks = ["0.0.0.0/0"]
	from_port = 0
	protocol = "-1"
	security_group_id = aws_security_group.eks_compute.id
	to_port = 0
	type = "egress"
}

resource "aws_security_group_rule" "eks_compute_internal" {
	from_port = 0
	protocol = "-1"
	security_group_id = aws_security_group.eks_compute.id
	self = true
	to_port = 0
	type = "ingress"
}

# resource "aws_security_group_rule" "eks_compute_ingress" {
# 	from_port = 1025
# 	protocol = "tcp"
# 	security_group_id = aws_security_group.eks_worker.id
# 	source_security_group_id = aws_security_group.eks_cluster.id
# 	to_port = 65535
# 	type = "ingress"
# }

# resource "aws_security_group_rule" "eks_compute_ingress_bastion_ssh" {
# 	from_port = 22
# 	protocol = "tcp"
# 	security_group_id = aws_security_group.eks_compute.id
# 	source_security_group_id = data.terraform_remote_state.bastion.outputs.bastion_security_group_id
# 	to_port = 22
# 	type = "ingress"
# }

# resource "aws_security_group_rule" "eks_worker_ingress_https" {
# 	from_port = 443
# 	protocol = "tcp"
# 	security_group_id = aws_security_group.eks_worker.id
# 	source_security_group_id = aws_security_group.eks_cluster.id
# 	to_port = 443
# 	type = "ingress"
# }