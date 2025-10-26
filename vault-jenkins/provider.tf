provider "aws" {
  region  = "eu-west-2"
  profile = "sock_shop"
}

terraform {
  backend "s3" {
    bucket       = "bucket-pet-adoption6467"
    key          = "vault-jenkins/terraform.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    profile      = "sock_shop"
    use_lockfile = true
  }
}