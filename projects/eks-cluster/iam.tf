data "aws_iam_policy" "eks_cluster" {
	arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

data "aws_iam_policy_document" "eks_assume_role_policy" {
	statement {
		actions = ["sts:AssumeRole"]
		principals {
			type = "Service"
			identifiers = ["eks.amazonaws.com"]
		}
	}
}

resource "aws_iam_role" "eks_cluster" {
	name = "${var.eks_cluster_name}-eks-cluster"
	assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "eks_cluster"  {
	role = aws_iam_role.eks_cluster.name
	policy_arn = data.aws_iam_policy.eks_cluster.arn
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