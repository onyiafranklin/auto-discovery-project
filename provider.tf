provider "aws" {
  region  = "eu-west-2"
  profile = "default"
}
terraform {
  backend "s3" {
    bucket = "bucket-pet-adoption1"
    key    = "infrastructure/terraform.tfstate"
    region = "eu-west-2"
    profile = "default"
    encrypt = true
    use_lockfile = true
  }
}