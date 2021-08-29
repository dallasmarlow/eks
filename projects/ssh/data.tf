data "aws_ip_ranges" "ec2_instance_connect" {
  regions  = [var.region]
  services = ["ec2_instance_connect"]
}