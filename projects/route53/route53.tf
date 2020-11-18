resource "aws_route53_zone" "primary" {
	name = var.route53_zone_domain
}

resource "aws_route53_record" "bastion" {
	zone_id = aws_route53_zone.primary.zone_id
	name    = "bastion.svc.${var.route53_zone_domain}"
	type    = "A"
	ttl     = "300"
	records = [data.terraform_remote_state.bastion.outputs.bastion_ip]
}

resource "aws_route53_record" "paste" {
	zone_id = aws_route53_zone.primary.zone_id
	name    = "pst.svc.${var.route53_zone_domain}"
	type    = "A"
	ttl     = "300"
	records = [data.terraform_remote_state.bastion.outputs.bastion_ip]
}