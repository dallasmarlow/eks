resource "aws_route53_zone" "primary" {
	name = var.route53_zone_domain
}

resource "aws_route53_record" "bastion" {
	zone_id = aws_route53_zone.primary.zone_id
	name    = "bastion.svc.${var.route53_zone_domain}"
	type    = "A"
	ttl     = "300"
	records = [data.terraform_remote_state.bastion.outputs.eip]
}

resource "aws_route53_record" "helm" {
	zone_id = aws_route53_zone.primary.zone_id
	name = var.helm_repo_domain
	type = "A"
	alias {
		evaluate_target_health = false
		name = data.terraform_remote_state.eks_cluster.outputs.s3_bucket_helm_repo_website_domain
		zone_id = data.terraform_remote_state.eks_cluster.outputs.s3_bucket_helm_repo_zone_id
	}
}