data "aws_iam_policy" "ecr_read_only" {
	arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

data "aws_iam_policy" "eks_cni" {
	arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

data "aws_iam_policy" "eks_compute" {
	arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
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

resource "aws_iam_role" "eks_compute" {
	name_prefix = "eks-compute-"
	assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "eks_compute_ecr_ro"  {
	role = aws_iam_role.eks_compute.name
	policy_arn = data.aws_iam_policy.ecr_read_only.arn
}

resource "aws_iam_role_policy_attachment" "eks_compute_cni"  {
	role = aws_iam_role.eks_compute.name
	policy_arn = data.aws_iam_policy.eks_cni.arn
}

resource "aws_iam_role_policy_attachment" "eks_compute"  {
	role = aws_iam_role.eks_compute.name
	policy_arn = data.aws_iam_policy.eks_compute.arn
}

resource "aws_iam_instance_profile" "eks_compute" {
	name_prefix = "eks-compute-"
	role = aws_iam_role.eks_compute.name
	depends_on = [
		aws_iam_role_policy_attachment.eks_compute,
		aws_iam_role_policy_attachment.eks_compute_cni,
		aws_iam_role_policy_attachment.eks_compute_ecr_ro,
	]
}
