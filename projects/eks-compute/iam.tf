data "aws_iam_policy" "ecr_read_only" {
	arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

data "aws_iam_policy" "eks_cni" {
	arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

data "aws_iam_policy" "eks_compute" {
	arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}