variable "account_id" {
  type    = string
  default = "052780769609"
}

variable "availability_zones" {
  type    = number
  default = 2
}

variable "bastion_arch" {
  type    = string
  default = "arm64"
}

variable "bastion_ebs_volume_size" {
  type    = number
  default = 10 # GB
}

variable "bastion_instance_type" {
  type    = string
  default = "t4g.nano"
}

variable "cloudwatch_log_group_retention_in_days" {
  type    = number
  default = 1
}

variable "ec2_user" {
  type    = string
  default = "ec2-user"
}

variable "eks_cluster_logs_retention_days" {
  type    = number
  default = 1
}

variable "eks_cluster_name" {
  type    = string
  default = "eks-test"
}

variable "eks_compute_instance_type" {
  type    = string
  default = "t3a.medium"
}

variable "eks_cluster_log_types" {
  type = list(string)
  default = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler",
  ]
}

variable "eks_primary_networks" {
  type = list(string)
  default = [
    "10.200.100.0/28",
    "10.200.100.16/28",
  ]
}

variable "eks_public_networks" {
  type = list(string)
  default = [
    "10.200.100.32/28",
    "10.200.100.48/28",
  ]
}

variable "eks_version" {
  type    = string
  default = "1.21"
}

variable "eks_vpc_network" {
  type    = string
  default = "10.200.100.0/26"
}


# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html#access-logging-bucket-permissions

variable "elb_account_ids" {
  type = map(any)
  default = {
    us-east-1      = "127311923021"
    us-east-2      = "033677994240"
    us-west-1      = "027434742980"
    us-west-2      = "797873946194"
    af-south-1     = "098369216593"
    ca-central-1   = "985666609251"
    eu-central-1   = "054676820928"
    eu-west-1      = "156460612806"
    eu-west-2      = "652711504416"
    eu-south-1     = "635631232127"
    eu-west-3      = "009996457667"
    eu-north-1     = "897822967062"
    ap-east-1      = "754344448648"
    ap-northeast-1 = "582318560864"
    ap-northeast-2 = "600734575887"
    ap-northeast-3 = "383597477331"
    ap-southeast-1 = "114774131450"
    ap-southeast-2 = "783225319266"
    ap-south-1     = "718504428378"
    me-south-1     = "076674570225"
    sa-east-1      = "507241528517"
  }
}

variable "elb_logs_s3_lifecyle_expire_days" {
  type    = number
  default = 7
}

variable "elb_logs_s3_lifecyle_incomplete_multipart_upload_expire_days" {
  type    = number
  default = 1
}

variable "helm_repo_domain" {
  type    = string
  default = "helm.svc.cl0wn.shoes"
}

variable "helm_url" {
  type    = string
  default = "https://get.helm.sh/helm-v3.5.4-linux-arm64.tar.gz"
  # default = "https://get.helm.sh/helm-v3.5.4-linux-amd64.tar.gz"
}

variable "kubectl_url" {
  type    = string
  default = "https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.5/2022-01-21/bin/linux/arm64/kubectl"
}

# this value needs to be computed based on the instance type, due to the custom CNI pod networking
# setup used by this automation the formula for deriving the value is:
# maxPods = (numInterfaces - 1) * (maxIpv4PerInterface - 1) + numDaemonSetsRunningInHostMode

# the base number of daemonsets deployed is 2 (aws-node and kube-proxy)
# ENI limits per-instance type can be found at: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html
variable "kubelet_max_pods" {
  type    = number
  default = 12
}

variable "k8s_pod_network" {
  type    = string
  default = "100.64.0.0/20"
}

variable "k8s_pod_networks" {
  type = list(string)
  default = [
    "100.64.0.0/21",
    "100.64.8.0/21",
  ]
}

variable "region" {
  type    = string
  default = "us-east-2"
}

variable "remote_network" {
  type    = string
  default = "104.162.77.104/32"
}

variable "route53_zone_domain" {
  type    = string
  default = "cl0wn.shoes"
}

variable "terraform_url" {
  type    = string
  default = "https://releases.hashicorp.com/terraform/1.1.7/terraform_1.1.7_linux_arm64.zip"
}
