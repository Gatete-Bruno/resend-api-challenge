# ============================================================================
# AWS & General Configuration
# ============================================================================

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
  default     = "bird-api"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

# ============================================================================
# EKS Cluster Configuration
# ============================================================================

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "bird-api-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.29"
}

variable "enable_cluster_autoscaler" {
  description = "Enable Cluster Autoscaler for automatic node scaling"
  type        = bool
  default     = true
}

variable "enable_metrics_server" {
  description = "Enable Kubernetes Metrics Server for HPA"
  type        = bool
  default     = true
}

# ============================================================================
# Node Group Configuration
# ============================================================================

variable "node_group_name" {
  description = "Name of the EKS node group"
  type        = string
  default     = "bird-api-nodes"
}

variable "node_group_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
  validation {
    condition     = var.node_group_desired_size >= 2
    error_message = "Desired size must be at least 2 for high availability."
  }
}

variable "node_group_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 2
  validation {
    condition     = var.node_group_min_size >= 2
    error_message = "Minimum size must be at least 2 for high availability."
  }
}

variable "node_group_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 5
  validation {
    condition     = var.node_group_max_size >= 3
    error_message = "Maximum size must be at least 3 for proper scaling."
  }
}

variable "node_instance_types" {
  description = "EC2 instance types for node group (priority order)"
  type        = list(string)
  default     = ["t2.medium"]
}

variable "node_disk_size" {
  description = "Disk size in GB for worker nodes"
  type        = number
  default     = 50
}

variable "node_tags" {
  description = "Additional tags for node group"
  type        = map(string)
  default = {
    NodeType = "ApplicationServer"
  }
}

# ============================================================================
# VPC Configuration
# ============================================================================

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "enable_vpn_gateway" {
  description = "Enable VPN Gateway"
  type        = bool
  default     = false
}

# ============================================================================
# Container Images
# ============================================================================

variable "bird_api_image" {
  description = "Docker image URI for bird-api"
  type        = string
  default     = "bruno74t/bird-api:v.1.0.5"
}

variable "bird_api_port" {
  description = "Port for bird-api container"
  type        = number
  default     = 4201
}

variable "bird_image_api_image" {
  description = "Docker image URI for bird-image-api"
  type        = string
  default     = "bruno74t/bird-image-api:v.1.0.5"
}

variable "bird_image_api_port" {
  description = "Port for bird-image-api container"
  type        = number
  default     = 4200
}

variable "bird_frontend_image" {
  description = "Docker image URI for bird-frontend"
  type        = string
  default     = "bruno74t/bird-frontend:v.1.0.5.5"
}

variable "bird_frontend_port" {
  description = "Port for bird-frontend container"
  type        = number
  default     = 3000
}

# ============================================================================
# Application Configuration
# ============================================================================

variable "bird_api_replicas" {
  description = "Number of replicas for bird-api deployment"
  type        = number
  default     = 2
  validation {
    condition     = var.bird_api_replicas >= 2
    error_message = "Must have at least 2 replicas for high availability."
  }
}

variable "bird_image_api_replicas" {
  description = "Number of replicas for bird-image-api deployment"
  type        = number
  default     = 2
  validation {
    condition     = var.bird_image_api_replicas >= 2
    error_message = "Must have at least 2 replicas for high availability."
  }
}

variable "bird_frontend_replicas" {
  description = "Number of replicas for bird-frontend deployment"
  type        = number
  default     = 2
  validation {
    condition     = var.bird_frontend_replicas >= 2
    error_message = "Must have at least 2 replicas for high availability."
  }
}

variable "hpa_enabled" {
  description = "Enable Horizontal Pod Autoscaler"
  type        = bool
  default     = true
}

variable "hpa_min_replicas" {
  description = "Minimum replicas for HPA"
  type        = number
  default     = 2
  validation {
    condition     = var.hpa_min_replicas >= 2
    error_message = "HPA minimum replicas must be at least 2."
  }
}

variable "hpa_max_replicas" {
  description = "Maximum replicas for HPA"
  type        = number
  default     = 10
  validation {
    condition     = var.hpa_max_replicas >= 2
    error_message = "HPA maximum replicas must be at least 2."
  }
}

variable "hpa_target_cpu_utilization" {
  description = "Target CPU utilization percentage for HPA"
  type        = number
  default     = 70
  validation {
    condition     = var.hpa_target_cpu_utilization > 0 && var.hpa_target_cpu_utilization <= 100
    error_message = "HPA target CPU utilization must be between 1 and 100."
  }
}

# ============================================================================
# Monitoring & Logging
# ============================================================================

variable "enable_cloudwatch_monitoring" {
  description = "Enable CloudWatch Container Insights"
  type        = bool
  default     = true
}

variable "log_retention_in_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_in_days)
    error_message = "Log retention must be a valid CloudWatch value."
  }
}

variable "enable_alb" {
  description = "Enable Application Load Balancer"
  type        = bool
  default     = true
}

# ============================================================================
# Tagging Strategy
# ============================================================================

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Owner      = "DevOps Team"
    CostCenter = "Engineering"
    Terraform  = "true"
  }
}