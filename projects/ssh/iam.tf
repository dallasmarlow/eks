data "aws_iam_policy_document" "ec2_instance_connect" {
	statement {
		actions = ["ec2-instance-connect:SendSSHPublicKey"]
		resources = ["arn:aws:ec2:${var.region}:${var.account_id}:instance/*"]
		condition {
			test = "StringEquals"
			variable = "ec2:osuser"
			values = [
				var.ec2_user,
			]
		}
		# condition {
		# 	test = "StringEquals"
		# 	variable = "ec2:Vpc"
		# 	values = [
		# 		data.terraform_remote_state.vpc.outputs.eks_test_vpc_arn,
		# 	]
		# }
	}
}

resource "aws_iam_policy" "ec2_instance_connect" {
	name_prefix = "ec2-instance-connect"
	policy = data.aws_iam_policy_document.ec2_instance_connect.json
}