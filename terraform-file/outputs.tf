output "s3_bucket_name" {
  description = "S3 bucket name — used in GitHub Actions aws s3 sync command"
  value       = aws_s3_bucket.portfolio.id
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.portfolio.arn
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID — used in GitHub Actions cache invalidation"
  value       = aws_cloudfront_distribution.portfolio.id
}

output "cloudfront_domain_name" {
  description = "CloudFront domain (e.g. xxxx.cloudfront.net) — for DNS verification"
  value       = aws_cloudfront_distribution.portfolio.domain_name
}

output "cloudfront_distribution_arn" {
  description = "CloudFront distribution ARN"
  value       = aws_cloudfront_distribution.portfolio.arn
}

output "certificate_arn" {
  description = "ACM certificate ARN"
  value       = aws_acm_certificate.portfolio.arn
}

output "certificate_status" {
  description = "ACM certificate validation status — should be ISSUED"
  value       = aws_acm_certificate.portfolio.status
}

output "site_url" {
  description = "Live site URL"
  value       = "https://${var.domain_name}"
}

