locals {
  domains = [
    "haulrest.me",
    "tinyclover.com"
  ]
}

# Route53 Hosted Zones
resource "aws_route53_zone" "domains" {
  for_each = toset(local.domains)
  name = each.value
  
  tags = merge(var.tags, {
    Name = each.value
    Type = "hosted-zone"
  })
}