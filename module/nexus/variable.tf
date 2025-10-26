variable "name" {}
variable "vpc_id" {}
variable "subnet_id" {}
variable "subnet_ids" {}
variable "key_name" {}
variable "domain_name" {}
variable "cert" {}
variable "nr-key" {
  description = "New Relic API Key"
}
variable "nr-id" {
  description = "New Relic Account ID"
}
variable "region" {default = "eu-west-2"}