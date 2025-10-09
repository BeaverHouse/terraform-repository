# IAM Policy for DNS management (ExternalDNS + cert-manager)
data "aws_iam_policy_document" "dns_manager_policy" {
  # Route53 permissions for ExternalDNS
  statement {
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
      "route53:ListHostedZonesByName",
      "route53:GetChange"
    ]
    resources = ["*"]
  }
  
  # Additional permissions for cert-manager ACME DNS challenge
  statement {
    effect = "Allow"
    actions = [
      "route53:GetChange",
      "route53:ListHostedZonesByName"
    ]
    resources = ["*"]
  }
}

# IAM User for DNS management (ExternalDNS + cert-manager)
resource "aws_iam_user" "dns_manager_user" {
  name = "dns-manager-user"
  path = "/"

  tags = merge(var.tags, {
    Name = "dns-manager-user"
    Purpose = "ExternalDNS and cert-manager"
  })
}

# IAM Policy attachment
resource "aws_iam_user_policy" "dns_manager_policy" {
  name = "dns-manager-policy"
  user = aws_iam_user.dns_manager_user.name
  policy = data.aws_iam_policy_document.dns_manager_policy.json
}

# IAM Access Key for the user
resource "aws_iam_access_key" "dns_manager_access_key" {
  user = aws_iam_user.dns_manager_user.name
}

output "dns_manager_access_key_id" {
  description = "Access Key ID for DNS management user"
  value       = aws_iam_access_key.dns_manager_access_key.id
}

output "dns_manager_secret_access_key" {
  description = "Secret Access Key for DNS management user"
  value       = aws_iam_access_key.dns_manager_access_key.secret
  sensitive   = true
}