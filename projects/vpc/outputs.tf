output "pod_subnet_ids" {
  value = [
    for s in aws_subnet.pod : s.id
  ]
}

output "primary_subnet_ids" {
  value = [
    for s in aws_subnet.primary : s.id
  ]
}

output "public_subnet_ids" {
  value = [
    for s in aws_subnet.public : s.id
  ]
}

output "s3_endpoint_id" {
  value = aws_vpc_endpoint.gateway_endpoints["s3"].id
}

output "vpc_arn" {
  value = aws_vpc.primary.arn
}

output "vpc_id" {
  value = aws_vpc.primary.id
}

output "vpc_network" {
  value = aws_vpc.primary.cidr_block
}