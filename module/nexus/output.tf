output "nexus_instance_id" {
  value = aws_instance.nexus.id
}

output "nexus_public_ip" {
  value = aws_instance.nexus.public_ip
}

output "alb_dns_name" {
  value = aws_elb.nexus_elb.dns_name
}

output "route53_record" {
  value = aws_route53_record.nexus_dns.fqdn
}

