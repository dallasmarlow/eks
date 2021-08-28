data "aws_availability_zones" "azs" {
  state = "available"
}

data "aws_vpc_endpoint_service" "gateway_endpoints" {
  for_each     = local.vpc_gateway_endpoints
  service      = each.key
  service_type = "Gateway"
}