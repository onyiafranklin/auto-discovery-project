provider "aws" {
  region  = "eu-west-2"
  profile = "default"
}

terraform {
  backend "s3" {
    bucket       = "bucket-pet-adoption1"
    key          = "vault-jenkins/terraform.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    profile      = "default"
    use_lockfile = true
  }
}