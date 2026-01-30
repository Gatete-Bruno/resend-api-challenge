# ============================================================================
# AWS & General Configuration
# ============================================================================

aws_region = "us-east-1"
project_name = "bird-api"
environment = "dev"

# ============================================================================
# EKS Cluster Configuration
# ============================================================================

cluster_name = "bird-api-cluster"
cluster_version = "1.29"
enable_cluster_autoscaler = true
enable_metrics_server = true

# ============================================================================
# Node Group Configuration
# ============================================================================

node_group_name = "bird-api-nodes"
node_group_desired_size = 2
node_group_min_size = 2
node_group_max_size = 5
node_instance_types = ["t2.medium"]
node_disk_size = 50

# ============================================================================
# VPC Configuration
# ============================================================================

vpc_cidr = "10.0.0.0/16"
enable_nat_gateway = true
enable_vpn_gateway = false

# ============================================================================
# Application Configuration
# ============================================================================

bird_api_replicas = 2
bird_image_api_replicas = 2
bird_frontend_replicas = 2
hpa_enabled = true
hpa_min_replicas = 2
hpa_max_replicas = 10
hpa_target_cpu_utilization = 70

# ============================================================================
# Monitoring & Logging
# ============================================================================

alert_email = "brunogatete77@gmail.com"

enable_cloudwatch_monitoring = true
log_retention_in_days = 7
enable_alb = true
