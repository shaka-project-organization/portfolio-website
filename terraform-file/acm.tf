# ──────────────────────────────────────────────
# ACM CERTIFICATE
# Must use the us_east_1 provider alias —
# CloudFront only accepts certs from us-east-1
# ──────────────────────────────────────────────

resource "aws_acm_certificate" "portfolio" {
  provider = aws.us_east_1

  domain_name               = var.domain_name
  subject_alternative_names = [var.www_domain_name]
  validation_method         = "DNS"

  lifecycle {
    # Create the new cert before destroying the old one
    # so there is zero downtime during certificate rotation
    create_before_destroy = true
  }
}

# ──────────────────────────────────────────────
# DNS VALIDATION RECORDS
# AWS gives us CNAME records to prove domain ownership.
# Terraform creates them in Route 53 automatically.
# for_each handles both the root and www SANs.
# ──────────────────────────────────────────────


# ──────────────────────────────────────────────
# CERTIFICATE VALIDATION WAITER
# Terraform pauses here until ACM confirms the
# certificate status is ISSUED before moving on.
# CloudFront creation depends on this resource.
# ──────────────────────────────────────────────

resource "aws_acm_certificate_validation" "portfolio" {
  provider = aws.us_east_1

  certificate_arn         = aws_acm_certificate.portfolio.arn

}
