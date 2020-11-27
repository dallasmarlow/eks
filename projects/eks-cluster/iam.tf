data "aws_iam_policy" "eks_cluster" {
	arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

data "aws_iam_policy_document" "eks_assume_role_policy" {
	statement {
		actions = ["sts:AssumeRole"]
		principals {
			type = "Service"
			identifiers = ["eks.amazonaws.com"]
		}
	}
}

resource "aws_iam_role" "eks_cluster" {
	name = "${var.eks_cluster_name}-eks-cluster"
	assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "eks_cluster"  {
	role = aws_iam_role.eks_cluster.name
	policy_arn = data.aws_iam_policy.eks_cluster.arn
}

# https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
# 3265d5ced519c76282478e3e896f9f53dc6eea56

data "aws_iam_policy_document" "aws_lb_controller" {
	statement {
		actions = [
			"iam:CreateServiceLinkedRole",
			"ec2:DescribeAccountAttributes",
			"ec2:DescribeAddresses",
			"ec2:DescribeInternetGateways",
			"ec2:DescribeVpcs",
			"ec2:DescribeSubnets",
			"ec2:DescribeSecurityGroups",
			"ec2:DescribeInstances",
			"ec2:DescribeNetworkInterfaces",
			"ec2:DescribeTags",
			"elasticloadbalancing:DescribeLoadBalancers",
			"elasticloadbalancing:DescribeLoadBalancerAttributes",
			"elasticloadbalancing:DescribeListeners",
			"elasticloadbalancing:DescribeListenerCertificates",
			"elasticloadbalancing:DescribeSSLPolicies",
			"elasticloadbalancing:DescribeRules",
			"elasticloadbalancing:DescribeTargetGroups",
			"elasticloadbalancing:DescribeTargetGroupAttributes",
			"elasticloadbalancing:DescribeTargetHealth",
			"elasticloadbalancing:DescribeTags",
		]
		resources = ["*"]
	}
	statement {
		actions = [
			"cognito-idp:DescribeUserPoolClient",
			"acm:ListCertificates",
			"acm:DescribeCertificate",
			"iam:ListServerCertificates",
			"iam:GetServerCertificate",
			"waf-regional:GetWebACL",
			"waf-regional:GetWebACLForResource",
			"waf-regional:AssociateWebACL",
			"waf-regional:DisassociateWebACL",
			"wafv2:GetWebACL",
			"wafv2:GetWebACLForResource",
			"wafv2:AssociateWebACL",
			"wafv2:DisassociateWebACL",
			"shield:GetSubscriptionState",
			"shield:DescribeProtection",
			"shield:CreateProtection",
			"shield:DeleteProtection",
		]
		resources = ["*"]
	}
	statement {
		actions = [
			"ec2:AuthorizeSecurityGroupIngress",
			"ec2:RevokeSecurityGroupIngress",
		]
		resources = ["*"]
	}
	statement {
		actions = [
			"ec2:CreateSecurityGroup",
		]
		resources = ["*"]
	}
	statement {
		actions = [
			"ec2:CreateTags",
		]
		condition {
			test = "Null"
			variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
			values = ["false"]
		}
		condition {
			test = "StringEquals"
			variable = "ec2:CreateAction"
			values = ["CreateSecurityGroup"]
		}
		resources = ["arn:aws:ec2:*:*:security-group/*"]
	}
	statement {
		actions = [
			"ec2:CreateTags",
			"ec2:DeleteTags",
		]
		condition {
			test = "Null"
			variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
			values = ["true"]
		}
		condition {
			test = "Null"
			variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
			values = ["false"]
		}
		resources = ["arn:aws:ec2:*:*:security-group/*"]
	}
	statement {
		actions = [
			"ec2:AuthorizeSecurityGroupIngress",
			"ec2:RevokeSecurityGroupIngress",
			"ec2:DeleteSecurityGroup",
		]
		condition {
			test = "Null"
			variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
			values = ["false"]
		}
		resources = ["*"]
	}
	statement {
		actions = [
			"elasticloadbalancing:CreateLoadBalancer",
			"elasticloadbalancing:CreateTargetGroup",
		]
		condition {
			test = "Null"
			variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
			values = ["false"]
		}
		resources = ["*"]
	}
	statement {
		actions = [
			"elasticloadbalancing:CreateListener",
			"elasticloadbalancing:DeleteListener",
			"elasticloadbalancing:CreateRule",
			"elasticloadbalancing:DeleteRule",
		]
		resources = ["*"]
	}
	statement {
		actions = [
			"elasticloadbalancing:AddTags",
			"elasticloadbalancing:RemoveTags",
		]
		condition {
			test = "Null"
			variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
			values = ["true"]
		}
		condition {
			test = "Null"
			variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
			values = ["false"]
		}
		resources = [
			"arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
			"arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
			"arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*",
		]
	}
	statement {
		actions = [
			"elasticloadbalancing:ModifyLoadBalancerAttributes",
			"elasticloadbalancing:SetIpAddressType",
			"elasticloadbalancing:SetSecurityGroups",
			"elasticloadbalancing:SetSubnets",
			"elasticloadbalancing:DeleteLoadBalancer",
			"elasticloadbalancing:ModifyTargetGroup",
			"elasticloadbalancing:ModifyTargetGroupAttributes",
			"elasticloadbalancing:DeleteTargetGroup",
		]
		condition {
			test = "Null"
			variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
			values = ["false"]
		}
		resources = ["*"]
	}
	statement {
		actions = [
			"elasticloadbalancing:RegisterTargets",
			"elasticloadbalancing:DeregisterTargets",
		]
		resources = [
			"arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
		]
	}
	statement {
		actions = [
			"elasticloadbalancing:SetWebAcl",
			"elasticloadbalancing:ModifyListener",
			"elasticloadbalancing:AddListenerCertificates",
			"elasticloadbalancing:RemoveListenerCertificates",
			"elasticloadbalancing:ModifyRule",
		]
		resources = ["*"]
	}
}


data "aws_iam_policy_document" "aws_lb_controller_trust_policy" {
	statement {
		actions = [
			"sts:AssumeRoleWithWebIdentity",
		]
		condition {
			test = "StringEquals"
			variable = join(":", [
				replace(aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", ""),
				"sub",
			])
			values = [
				"system:serviceaccount:kube-system:aws-load-balancer-controller",
			]
		}
		principals {
			type = "Federated"
			identifiers = [
				aws_iam_openid_connect_provider.eks_cluster.arn,
			]
		}
	}
}

resource "aws_iam_policy" "aws_lb_controller" {
	name_prefix = "aws-lb-controller"
	policy = data.aws_iam_policy_document.aws_lb_controller.json
}

resource "aws_iam_role" "aws_lb_controller" {
	name = "${var.eks_cluster_name}-aws-lb-controller"
	assume_role_policy = data.aws_iam_policy_document.aws_lb_controller_trust_policy.json
}

resource "aws_iam_role_policy_attachment" "aws_lb_controller"  {
	role = aws_iam_role.aws_lb_controller.name
	policy_arn = aws_iam_policy.aws_lb_controller.arn
}