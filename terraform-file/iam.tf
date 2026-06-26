
resource "aws_iam_user" "github_deployer" {
  name = "github-portfolio-deployer"
  path = "/ci/"
}

resource "aws_iam_access_key" "github_deployer" {
  user = aws_iam_user.github_deployer.name
}

# ── DEPLOYMENT POLICY ──
# Scoped to exactly this bucket and distribution
resource "aws_iam_policy" "github_deployer" {
  name        = "PortfolioGitHubDeployerPolicy"
  description = "Allows GitHub Actions to sync files to S3 and invalidate CloudFront cache"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3SyncAccess"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.portfolio.arn,
          "${aws_s3_bucket.portfolio.arn}/*"
        ]
      },
      {
        Sid    = "CloudFrontInvalidation"
        Effect = "Allow"
        Action = [
          "cloudfront:CreateInvalidation",
          "cloudfront:GetDistribution"
        ]
        Resource = aws_cloudfront_distribution.portfolio.arn
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "github_deployer" {
  user       = aws_iam_user.github_deployer.name
  policy_arn = aws_iam_policy.github_deployer.arn
}

# ──────────────────────────────────────────────
# OUTPUTS — IAM CREDENTIALS
# These go into GitHub Secrets.
# Marked sensitive so they don't print in logs.
# ──────────────────────────────────────────────

output "github_deployer_access_key_id" {
  description = "Add this as AWS_ACCESS_KEY_ID in GitHub Secrets"
  value       = aws_iam_access_key.github_deployer.id
  sensitive   = true
}

output "github_deployer_secret_access_key" {
  description = "Add this as AWS_SECRET_ACCESS_KEY in GitHub Secrets"
  value       = aws_iam_access_key.github_deployer.secret
  sensitive   = true
}
