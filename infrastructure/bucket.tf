# ============================================================================
# S3 Bucket for Terraform State
# ============================================================================

resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.project_name}-terraform-state-${data.aws_caller_identity.current.account_id}"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-terraform-state"
    }
  )
}

# ============================================================================
# S3 Bucket Versioning
# ============================================================================

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ============================================================================
# S3 Bucket Encryption
# ============================================================================

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ============================================================================
# S3 Bucket Public Access Block
# ============================================================================

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ============================================================================
# DynamoDB Table for Terraform State Locking
# ============================================================================

resource "aws_dynamodb_table" "terraform_locks" {
  name           = "${var.project_name}-terraform-locks"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-terraform-locks"
    }
  )
}

# ============================================================================
# Outputs
# ============================================================================

output "s3_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.id
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  value       = aws_dynamodb_table.terraform_locks.id
}

output "backend_config" {
  description = "Backend configuration for terraform"
  value = <<-EOT
    
    # Add this to your backend.tf after initial apply:
    
    backend "s3" {
      bucket         = "${aws_s3_bucket.terraform_state.id}"
      key            = "bird-api/terraform.tfstate"
      region         = "${var.aws_region}"
      encrypt        = true
      dynamodb_table = "${aws_dynamodb_table.terraform_locks.id}"
    }
    
  EOT
}
