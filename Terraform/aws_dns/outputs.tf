output "external_dns_access_id" {
  value = aws_iam_access_key.k8s.id
}

output "external_dns_access_secret" {
  value = nonsensitive(aws_iam_access_key.k8s.secret)
}