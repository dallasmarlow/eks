output "role_arn" {
  value = aws_iam_role.compute.arn
}

output "asg_name" {
  value = aws_autoscaling_group.compute.name
}

output "sg" {
  value = aws_security_group.compute.id
}
