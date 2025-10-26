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

module "bastion1" {
  source = "./module/bastion1"
  name = local.name
  privatekey = module.vpc.private_key
  nr-acc-id = var.newrelic_id
  nr-key = var.newrelic_key
  vpc_id = module.vpc.vpc_id
   subnet_id = module.vpc.pub_sub1_id
  region = var.region
  key_name = module.vpc.public_key  
}

module "sonarqube" {
  source = "./module/sonarqube"
  name = local.name
  vpc-id = module.vpc.vpc_id
  subnet_id = module.vpc.pub_sub1_id
  public_subnets = [module.vpc.pub_sub1_id, module.vpc.pub_sub2_id]
  key = module.vpc.public_key
  bastion = module.bastion1.bastion_sg
  domain = var.domain
  acm_certificate_arn = data.aws_acm_certificate.cert.arn
  nr-key = var.newrelic_key
  nr-id = var.newrelic_id
}
module "nexus" {
  source = "./module/nexus"
  name = local.name
  vpc_id = module.vpc.vpc_id
  subnet_id = module.vpc.pub_sub1_id
  subnet_ids = [module.vpc.pub_sub1_id, module.vpc.pub_sub2_id]
  key_name = module.vpc.public_key
  domain_name = var.domain
  cert = data.aws_acm_certificate.cert.arn
  nr-key = var.newrelic_key
  nr-id = var.newrelic_id
  
}