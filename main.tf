locals {
  name = "auto-discov"
}

data "aws_acm_certificate" "cert" {
  domain   = var.domain
  most_recent = true
  statuses = ["ISSUED"]
}

module "vpc" {
  source = "./module/vpc"
  name   = local.name
  az1    = var.az1
  az2    = var.az2
}