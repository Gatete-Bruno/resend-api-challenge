# ============================================================================
# Data Sources - Information about AWS account and resources
# ============================================================================

# Current AWS account ID
data "aws_caller_identity" "current" {}

# Available Availability Zones in the region (only use 2 for EKS)
data "aws_availability_zones" "available" {
  state = "available"
  filter {
    name   = "zone-name"
    values = ["us-east-1a", "us-east-1b"]
  }
}

# EKS optimized AMI for nodes
data "aws_ami" "eks_worker" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.cluster_version}-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Outputs for data sources
output "aws_account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "availability_zones" {
  description = "Available AZs in the region"
  value       = data.aws_availability_zones.available.names
}