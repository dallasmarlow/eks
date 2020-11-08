data "aws_iam_policy" "ecr_power_user" {
	arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

data "aws_iam_policy_document" "ec2_assume_role_policy" {
	statement {
		actions = ["sts:AssumeRole"]
		principals {
			type = "Service"
			identifiers = ["ec2.amazonaws.com"]
		}
	}
}

data "aws_iam_policy_document" "eks_read_only" {
	statement {
		actions = [
			"eks:DescribeCluster",
			"eks:ListClusters",
		]
		resources = ["*"]
	}
}

resource "aws_iam_policy" "eks_read_only" {
	name_prefix = "bastion-eks-read-only"
	policy = data.aws_iam_policy_document.eks_read_only.json
}

resource "aws_iam_role" "bastion" {
	name_prefix = "bastion-"
	assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "bastion_ec2_instance_connect" {
	role = aws_iam_role.bastion.name
	policy_arn = data.terraform_remote_state.ssh.outputs.ec2_instance_connect_policy_arn
}

resource "aws_iam_role_policy_attachment" "bastion_ecr_power_user" {
	role = aws_iam_role.bastion.name
	policy_arn = data.aws_iam_policy.ecr_power_user.arn
}

resource "aws_iam_role_policy_attachment" "bastion_eks_read_only"  {
	role = aws_iam_role.bastion.name
	policy_arn = aws_iam_policy.eks_read_only.arn
}

resource "aws_iam_role_policy_attachment" "terraform_dynamodb_locktable" {
	role = aws_iam_role.bastion.name
	policy_arn = data.terraform_remote_state.terraform_backend.outputs.iam_policy_terraform_dynamodb_locktable_arn
}

resource "aws_iam_role_policy_attachment" "terraform_s3_backend" {
	role = aws_iam_role.bastion.name
	policy_arn = data.terraform_remote_state.terraform_backend.outputs.iam_policy_terraform_s3_backend_arn
}

resource "aws_iam_instance_profile" "bastion_instance_profile" {
	name_prefix = "bastion-profile-"
	role = aws_iam_role.bastion.name
}