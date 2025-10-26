provider "aws" {
  region  = "eu-west-2"
  profile = "sock_shop"
}
terraform {
  backend "s3" {
    bucket = "bucket-pet-adoption6467"
    key    = "infrastructure/terraform.tfstate"
    region = "eu-west-2"
    profile = "sock_shop"
    encrypt = true
    use_lockfile = true
  }
}