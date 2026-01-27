# ============================================================================
# CloudFront Distribution for Bird API
# ============================================================================

resource "aws_cloudfront_distribution" "bird_api" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "CloudFront distribution for bird-api"

  # ============================================================================
  # Origin 1: Bird API Load Balancer
  # ============================================================================

  origin {
    domain_name = data.kubernetes_service.bird_api.status[0].load_balancer[0].ingress[0].hostname
    origin_id   = "bird-api-nlb"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # ============================================================================
  # Origin 2: Bird Image API Load Balancer
  # ============================================================================

  origin {
    domain_name = data.kubernetes_service.bird_image_api.status[0].load_balancer[0].ingress[0].hostname
    origin_id   = "bird-image-api-nlb"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # ============================================================================
  # Default Cache Behavior (Bird API)
  # ============================================================================

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "bird-api-nlb"

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }

      headers = [
        "Accept",
        "Accept-Charset",
        "Accept-Encoding",
        "Accept-Language",
        "Authorization",
        "Host",
        "Origin",
        "Referer",
        "User-Agent"
      ]
    }

    viewer_protocol_policy = "allow-all"
    default_ttl            = 300
    max_ttl                = 600
    min_ttl                = 0
  }

  # ============================================================================
  # Restrictions
  # ============================================================================

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # ============================================================================
  # Viewer Certificate
  # ============================================================================

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  # ============================================================================
  # Logging
  # ============================================================================

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.cloudfront_logs.bucket_domain_name
    prefix          = "cloudfront-logs"
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-cdn"
    }
  )

  depends_on = [
    aws_s3_bucket_acl.cloudfront_logs,
    kubernetes_service.bird_api,
    kubernetes_service.bird_image_api
  ]
}

# ============================================================================
# S3 Bucket for CloudFront Logs
# ============================================================================

resource "aws_s3_bucket" "cloudfront_logs" {
  bucket = "${var.project_name}-cloudfront-logs-${data.aws_caller_identity.current.account_id}"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-cloudfront-logs"
    }
  )
}

# ============================================================================
# S3 Bucket Versioning
# ============================================================================

resource "aws_s3_bucket_versioning" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ============================================================================
# S3 Bucket Ownership Controls (Required for ACL)
# ============================================================================

resource "aws_s3_bucket_ownership_controls" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }

  depends_on = [aws_s3_bucket.cloudfront_logs]
}

# ============================================================================
# S3 Bucket ACL
# ============================================================================

resource "aws_s3_bucket_acl" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id
  acl    = "private"

  depends_on = [aws_s3_bucket_ownership_controls.cloudfront_logs]
}

# ============================================================================
# S3 Bucket Public Access Block
# ============================================================================

resource "aws_s3_bucket_public_access_block" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket.cloudfront_logs]
}

# ============================================================================
# Data Sources - Get Load Balancer DNS Names
# ============================================================================

data "kubernetes_service" "bird_api" {
  metadata {
    name      = "bird-api-service"
    namespace = "default"
  }

  depends_on = [kubernetes_service.bird_api]
}

data "kubernetes_service" "bird_image_api" {
  metadata {
    name      = "bird-image-api-service"
    namespace = "default"
  }

  depends_on = [kubernetes_service.bird_image_api]
}

# ============================================================================
# Outputs
# ============================================================================

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.bird_api.domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.bird_api.id
}

output "bird_api_cloudfront_url" {
  description = "CloudFront URL for accessing bird-api"
  value       = "http://${aws_cloudfront_distribution.bird_api.domain_name}"
}

output "cloudfront_logs_bucket" {
  description = "S3 bucket for CloudFront logs"
  value       = aws_s3_bucket.cloudfront_logs.id
}