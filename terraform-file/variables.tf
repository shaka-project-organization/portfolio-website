variable "aws_region" {
  description = "Primary AWS region for all resources (except ACM which is always us-east-1)"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "production"
}

variable "domain_name" {
  description = "Root domain for the portfolio site"
  type        = string
  default     = "engrshakacloud.online"
}

variable "www_domain_name" {
  description = "www subdomain"
  type        = string
  default     = "www.engrshakacloud.online"
}

variable "bucket_name" {
  description = "S3 bucket name — must exactly match domain name for clarity"
  type        = string
  default     = "engrshakacloud.online"
}

variable "cloudfront_price_class" {
  description = "CloudFront price class — PriceClass_100 covers US/Europe/Asia, cheapest option"
  type        = string
  default     = "PriceClass_100"
}

variable "index_document" {
  description = "Default root object served by CloudFront"
  type        = string
  default     = "index.html"
}

variable "error_document" {
  description = "Custom error page — points back to index for SPA-style routing"
  type        = string
  default     = "index.html"
}
