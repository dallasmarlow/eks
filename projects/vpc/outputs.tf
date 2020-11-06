output "eks_test_vpc_id" {
	value = aws_vpc.eks_test.id
}

output "eks_test_vpc_network" {
	value = aws_vpc.eks_test.cidr_block
}

output "eks_test_pub_subnet_a" {
	value = aws_subnet.pub_subnet_a.id
}

output "eks_test_pub_subnet_b" {
	value = aws_subnet.pub_subnet_b.id
}

output "eks_test_priv_subnet_a" {
	value = aws_subnet.priv_subnet_a.id
}

output "eks_test_priv_subnet_b" {
	value = aws_subnet.priv_subnet_b.id
}

output "eks_test_pod_subnet_a" {
	value = aws_subnet.pod_subnet_a.id
}

output "eks_test_pod_subnet_b" {
	value = aws_subnet.pod_subnet_b.id
}

output "ssh_external_sg_id" {
	value = aws_security_group.external_ssh_ingress.id
}

output "ssh_internal_sg_id" {
	value = aws_security_group.internal_ssh_ingress.id
}