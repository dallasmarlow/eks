resource "aws_vpc" "eks_test" {
	cidr_block = var.eks_vpc_network
	enable_dns_support = true
	enable_dns_hostnames = true
	tags = {
		Name = "eks_test"
	}
}

resource "aws_subnet" "priv_subnet_a" {
	vpc_id = aws_vpc.eks_test.id
	cidr_block = var.eks_priv_subnet_a_network
	availability_zone = "${var.region}a"
	tags = {
		Name = "eks_test_priv_a"
		"kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
		# "kubernetes.io/role/internal-elb" = 1
	}
}

resource "aws_subnet" "priv_subnet_b" {
	vpc_id = aws_vpc.eks_test.id
	cidr_block = var.eks_priv_subnet_b_network
	availability_zone = "${var.region}b"
	tags = {
		Name = "eks_test_priv_b"
		"kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
		# "kubernetes.io/role/internal-elb" = 1
	}
}

resource "aws_subnet" "pub_subnet_a" {
	vpc_id = aws_vpc.eks_test.id
	cidr_block = var.eks_pub_subnet_a_network
	availability_zone = "${var.region}a"
	map_public_ip_on_launch = true
	tags = {
		Name = "eks_test_pub_a"
		"kubernetes.io/role/elb" = 1
	}
}

resource "aws_subnet" "pub_subnet_b" {
	vpc_id = aws_vpc.eks_test.id
	cidr_block = var.eks_pub_subnet_b_network
	availability_zone = "${var.region}b"
	map_public_ip_on_launch = true
	tags = {
		Name = "eks_test_pub_b"
		"kubernetes.io/role/elb" = 1
	}
}

# K8S pod network

resource "aws_vpc_ipv4_cidr_block_association" "k8s_pod_network" {
	vpc_id = aws_vpc.eks_test.id
	cidr_block = var.k8s_pod_network
}

resource "aws_subnet" "pod_subnet_a" {
	vpc_id = aws_vpc.eks_test.id
	cidr_block = var.k8s_pod_subnet_a_network
	availability_zone = "${var.region}a"
	depends_on = [aws_vpc_ipv4_cidr_block_association.k8s_pod_network]
	tags = {
		Name = "eks_test_pod_a"
		"kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
		"kubernetes.io/role/internal-elb" = 1
	}
}

resource "aws_subnet" "pod_subnet_b" {
	vpc_id = aws_vpc.eks_test.id
	cidr_block = var.k8s_pod_subnet_b_network
	availability_zone = "${var.region}b"
	depends_on = [aws_vpc_ipv4_cidr_block_association.k8s_pod_network]
	tags = {
		Name = "eks_test_pod_b"
		"kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
		"kubernetes.io/role/internal-elb" = 1
	}
}

# Internet Gateway

resource "aws_internet_gateway" "ig" {
	vpc_id = aws_vpc.eks_test.id
	tags = {
		Name = "eks_test_ig"
	}
}

resource "aws_route_table" "ig_egress" {
	vpc_id = aws_vpc.eks_test.id
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.ig.id
	}
	tags = {
		Name = "eks_test_ig_egress"
	}
}

resource "aws_route_table_association" "pub_subnet_a" {
	subnet_id = aws_subnet.pub_subnet_a.id
	route_table_id = aws_route_table.ig_egress.id
}

resource "aws_route_table_association" "pub_subnet_b" {
	subnet_id = aws_subnet.pub_subnet_b.id
	route_table_id = aws_route_table.ig_egress.id
}

# NAT gateways

resource "aws_eip" "nat_gateway_a" {
	vpc = true
	tags = {
		Name = "eks_test_nat_gateway_a"
	}
}

resource "aws_eip" "nat_gateway_b" {
	vpc = true
	tags = {
		Name = "eks_test_nat_gateway_b"
	}
}

resource "aws_nat_gateway" "nat_gateway_a" {
	allocation_id = aws_eip.nat_gateway_a.id
	subnet_id = aws_subnet.pub_subnet_a.id
	depends_on = [aws_internet_gateway.ig]
	tags = {
		Name = "eks_test_nat_gateway_a"
	}
}

resource "aws_nat_gateway" "nat_gateway_b" {
	allocation_id = aws_eip.nat_gateway_b.id
	subnet_id = aws_subnet.pub_subnet_b.id
	depends_on = [aws_internet_gateway.ig]
	tags = {
		Name = "eks_test_nat_gateway_b"
	}
}

# Routing

resource "aws_route_table" "nat_gateway_a_egress" {
	vpc_id = aws_vpc.eks_test.id
	route {
		cidr_block = "0.0.0.0/0"
		nat_gateway_id = aws_nat_gateway.nat_gateway_a.id
	}
	tags = {
		Name = "eks_test_nat_gateway_a_egress"
	}
}

resource "aws_route_table" "nat_gateway_b_egress" {
	vpc_id = aws_vpc.eks_test.id
	route {
		cidr_block = "0.0.0.0/0"
		nat_gateway_id = aws_nat_gateway.nat_gateway_b.id
	}
	tags = {
		Name = "eks_test_nat_gateway_b_egress"
	}
}

resource "aws_route_table_association" "priv_subnet_a" {
	subnet_id = aws_subnet.priv_subnet_a.id
	route_table_id = aws_route_table.nat_gateway_a_egress.id
}

resource "aws_route_table_association" "priv_subnet_b" {
	subnet_id = aws_subnet.priv_subnet_b.id
	route_table_id = aws_route_table.nat_gateway_b_egress.id
}

resource "aws_route_table_association" "pod_subnet_a" {
	subnet_id = aws_subnet.pod_subnet_a.id
	route_table_id = aws_route_table.nat_gateway_a_egress.id
}

resource "aws_route_table_association" "pod_subnet_b" {
	subnet_id = aws_subnet.pod_subnet_b.id
	route_table_id = aws_route_table.nat_gateway_b_egress.id
}

# SSH Security Groups

resource "aws_security_group" "external_ssh_ingress" {
	name_prefix = "external_ssh_ingress"
	vpc_id = aws_vpc.eks_test.id
	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = [
			var.remote_network,
		]
	}
	revoke_rules_on_delete = true
	tags = {
		Name = "external_ssh_ingress"
	}
}

resource "aws_security_group" "internal_ssh_ingress" {
	name_prefix = "internal_ssh_ingress"
	vpc_id = aws_vpc.eks_test.id
	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		self = true
	}
	revoke_rules_on_delete = true
	tags = {
		Name = "internal_ssh_ingress"
	}
}

# Endpoint

data "aws_vpc_endpoint_service" "s3" {
  service = "s3"
}

resource "aws_vpc_endpoint" "s3" {
	vpc_id = aws_vpc.eks_test.id
	vpc_endpoint_type   = "Gateway"
	private_dns_enabled = true
	route_table_ids = [
		aws_route_table.nat_gateway_a_egress.id,
		aws_route_table.nat_gateway_b_egress.id,
	]
	service_name = data.aws_vpc_endpoint_service.s3.service_name
	tags = {
		Name = "s3_endpoint"
	}
}