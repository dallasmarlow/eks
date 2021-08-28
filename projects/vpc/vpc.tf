locals {
  azs = slice(data.aws_availability_zones.azs.names, 0, var.availability_zones)
  primary_network_k8s_tags = {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"               = 1
  }
  public_network_k8s_tags = {
    "kubernetes.io/role/elb" = 1
  }
  vpc_gateway_endpoints = toset([
    "dynamodb",
    "s3",
  ])
}

resource "aws_vpc" "primary" {
  cidr_block           = var.eks_vpc_network
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.eks_cluster_name}-primary"
  }
}

resource "aws_subnet" "primary" {
  count = length(local.azs)

  availability_zone = local.azs[count.index]
  cidr_block        = var.eks_primary_networks[count.index]
  vpc_id            = aws_vpc.primary.id

  tags = merge(
    local.primary_network_k8s_tags,
    { Name = "${var.eks_cluster_name}-primary-${local.azs[count.index]}" },
  )
}

resource "aws_subnet" "public" {
  count = length(local.azs)

  availability_zone = local.azs[count.index]
  cidr_block        = var.eks_public_networks[count.index]
  vpc_id            = aws_vpc.primary.id

  tags = merge(
    local.public_network_k8s_tags,
    { Name = "${var.eks_cluster_name}-public-${local.azs[count.index]}" },
  )
}

# K8S pod network

resource "aws_vpc_ipv4_cidr_block_association" "k8s_pod_network" {
  vpc_id     = aws_vpc.primary.id
  cidr_block = var.k8s_pod_network
}

resource "aws_subnet" "pod" {
  count      = length(local.azs)
  depends_on = [aws_vpc_ipv4_cidr_block_association.k8s_pod_network]

  availability_zone = local.azs[count.index]
  cidr_block        = var.k8s_pod_networks[count.index]
  vpc_id            = aws_vpc.primary.id

  tags = {
    Name = "${var.eks_cluster_name}-pod-${local.azs[count.index]}"
  }
}

# Internet Gateway

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.primary.id
  tags = {
    Name = "${var.eks_cluster_name}-ig"
  }
}

# NAT gateways

resource "aws_eip" "nat_gateway" {
  count = length(local.azs)
  vpc   = true
  tags = {
    Name = "${var.eks_cluster_name}-nat-gateway-${local.azs[count.index]}"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  count      = length(local.azs)
  depends_on = [aws_internet_gateway.ig]

  allocation_id = aws_eip.nat_gateway[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags = {
    Name = "${var.eks_cluster_name}-nat-gateway-${local.azs[count.index]}"
  }
}

# Routing

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.primary.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }
  tags = {
    Name = "${var.eks_cluster_name}-public"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(local.azs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "primary" {
  count  = length(local.azs)
  vpc_id = aws_vpc.primary.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway[count.index].id
  }
  tags = {
    Name = "${var.eks_cluster_name}-primary-${local.azs[count.index]}"
  }
}

resource "aws_route_table_association" "primary" {
  count          = length(local.azs)
  subnet_id      = aws_subnet.primary[count.index].id
  route_table_id = aws_route_table.primary[count.index].id
}

resource "aws_route_table_association" "pod" {
  count          = length(local.azs)
  subnet_id      = aws_subnet.pod[count.index].id
  route_table_id = aws_route_table.primary[count.index].id
}

# VPC endpoints

resource "aws_vpc_endpoint" "gateway_endpoints" {
  for_each = local.vpc_gateway_endpoints
  route_table_ids = concat(
    [aws_route_table.public.id],
    [for t in aws_route_table.primary : t.id],
  )
  service_name      = data.aws_vpc_endpoint_service.gateway_endpoints[each.key].service_name
  vpc_endpoint_type = "Gateway"
  vpc_id            = aws_vpc.primary.id
}
