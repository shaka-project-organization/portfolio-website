resource "aws_s3_bucket" "portfolio" {
  bucket = var.bucket_name

  lifecycle {
    prevent_destroy = true
  }
}

# Block every form of public access
resource "aws_s3_bucket_public_access_block" "portfolio" {
  bucket = aws_s3_bucket.portfolio.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning — lets you roll back to a
# previous version of index.html if needed
resource "aws_s3_bucket_versioning" "portfolio" {
  bucket = aws_s3_bucket.portfolio.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Encryption at rest
resource "aws_s3_bucket_server_side_encryption_configuration" "portfolio" {
  bucket = aws_s3_bucket.portfolio.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ──────────────────────────────────────────────
# ORIGIN ACCESS CONTROL (OAC)
# Modern replacement for OAI. Grants CloudFront
# permission to read from the private S3 bucket.
# ──────────────────────────────────────────────

resource "aws_cloudfront_origin_access_control" "portfolio" {
  name                              = "${var.bucket_name}-oac"
  description                       = "OAC for ${var.domain_name} portfolio site"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# ──────────────────────────────────────────────
# S3 BUCKET POLICY
# Allows ONLY the specific CloudFront distribution
# to read objects. No other source can access S3.
# ──────────────────────────────────────────────

resource "aws_s3_bucket_policy" "portfolio" {
  bucket = aws_s3_bucket.portfolio.id
  policy = data.aws_iam_policy_document.s3_cloudfront.json

  # Bucket policy references CloudFront ARN,
  # so CloudFront must exist first
  depends_on = [aws_cloudfront_distribution.portfolio]
}

data "aws_iam_policy_document" "s3_cloudfront" {
  statement {
    sid    = "AllowCloudFrontServicePrincipal"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.portfolio.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.portfolio.arn]
    }
  }
}

# ──────────────────────────────────────────────
# CLOUDFRONT DISTRIBUTION
# CDN that sits in front of S3. Handles HTTPS,
# caching, compression, and global delivery.
# ──────────────────────────────────────────────

resource "aws_cloudfront_distribution" "portfolio" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.index_document
  comment             = "Portfolio site — ${var.domain_name}"
  price_class         = var.cloudfront_price_class

  # Custom domain names
  aliases = [var.domain_name, var.www_domain_name]

  # ── ORIGIN: S3 Bucket ──
  origin {
    domain_name              = aws_s3_bucket.portfolio.bucket_regional_domain_name
    origin_id                = "S3-${var.bucket_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.portfolio.id
  }

  # ── DEFAULT CACHE BEHAVIOUR ──
  default_cache_behavior {
    target_origin_id       = "S3-${var.bucket_name}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    # Use AWS managed caching policy — optimised for S3 static sites
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  # ── CUSTOM ERROR RESPONSES ──
  # When S3 returns 403/404, serve index.html with 200
  # This supports single-page app routing if needed
  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/${var.error_document}"
    error_caching_min_ttl = 10
  }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/${var.error_document}"
    error_caching_min_ttl = 10
  }

  # ── SSL CERTIFICATE ──
  # Depends on certificate being fully validated
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.portfolio.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  # ── GEO RESTRICTION ──
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  depends_on = [aws_acm_certificate_validation.portfolio]
}
