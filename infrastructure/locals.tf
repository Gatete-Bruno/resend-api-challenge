# ============================================================================
# Local Values - Used across multiple files for consistency
# ============================================================================

locals {
  cluster_name = var.cluster_name
  region       = var.aws_region
  environment  = var.environment
  project_name = var.project_name

  # Common tags applied to all resources
  common_tags = merge(
    var.common_tags,
    {
      Cluster     = local.cluster_name
      Environment = local.environment
      Project     = local.project_name
      ManagedBy   = "Terraform"
    }
  )

  # Availability zones in the region
  azs = data.aws_availability_zones.available.names

  # EKS cluster tags for ASG discovery
  eks_cluster_tags = {
    "k8s.io/cluster-autoscaler/${local.cluster_name}" = "owned"
  }

  # Container port mappings
  container_ports = {
    bird_api       = var.bird_api_port
    bird_image_api = var.bird_image_api_port
  }

  # Service naming
  services = {
    bird_api       = "bird-api-service"
    bird_image_api = "bird-image-api-service"
  }

  # Namespace
  namespace = "default"

  # Common annotations
  common_annotations = {
    "prometheus.io/scrape" = "true"
    "prometheus.io/port"   = "8080"
  }
}
