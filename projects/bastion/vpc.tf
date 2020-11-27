resource "aws_security_group" "bastion" {
	name = "bastion"
	vpc_id = data.terraform_remote_state.vpc.outputs.eks_test_vpc_id
	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
	revoke_rules_on_delete = true
	tags = {
		Name = "bastion"
	}
}