output "bastion_ip" {
	value = aws_eip.bastion.public_ip
}

output "bastion_security_group_id" {
	value = aws_security_group.bastion.id
}

output "bastion_role_arn" {
	value = aws_iam_role.bastion.arn
}