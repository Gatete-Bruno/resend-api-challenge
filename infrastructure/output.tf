# ============================================================================
# EKS Cluster Outputs
# ============================================================================

output "cluster_id" {
  description = "The name/id of the EKS cluster"
  value       = aws_eks_cluster.main.id
}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster"
  value       = aws_iam_role.eks_cluster_role.arn
}

# ============================================================================
# Node Group Outputs
# ============================================================================

output "node_group_id" {
  description = "EKS node group ID"
  value       = aws_eks_node_group.main.id
}

output "node_group_status" {
  description = "Status of the EKS node group"
  value       = aws_eks_node_group.main.status
}

output "node_iam_role_arn" {
  description = "IAM role ARN of the EKS node group"
  value       = aws_iam_role.eks_node_role.arn
}

# ============================================================================
# VPC Outputs
# ============================================================================

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

# ============================================================================
# Kubernetes Access
# ============================================================================

output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}"
}

output "get_token" {
  description = "Command to get authentication token"
  value       = "aws eks get-token --cluster-name ${aws_eks_cluster.main.name} --region ${var.aws_region}"
}

# ============================================================================
# Load Balancer Outputs (if enabled)
# ============================================================================

output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = try(kubernetes_service.bird_api[0].status[0].load_balancer[0].ingress[0].hostname, null)
  depends_on  = [aws_eks_node_group.main]
}

output "bird_api_service_endpoint" {
  description = "Endpoint for bird-api service"
  value       = try("http://${kubernetes_service.bird_api[0].status[0].load_balancer[0].ingress[0].hostname}", null)
  depends_on  = [aws_eks_node_group.main]
}

output "bird_image_api_service_endpoint" {
  description = "Endpoint for bird-image-api service"
  value       = try("http://${kubernetes_service.bird_image_api[0].status[0].load_balancer[0].ingress[0].hostname}", null)
  depends_on  = [aws_eks_node_group.main]
}

# ============================================================================
# Frontend Service Endpoint
# ============================================================================

output "bird_frontend_service_endpoint" {
  description = "Endpoint for bird-frontend service"
  value       = try("http://${kubernetes_service.bird_frontend[0].status[0].load_balancer[0].ingress[0].hostname}", null)
  depends_on  = [aws_eks_node_group.main]
}

# ============================================================================
# Quick Start Guide
# ============================================================================

output "quick_start" {
  description = "Quick start guide"
  value = <<-EOT
    
    ========== BIRD API INFRASTRUCTURE SETUP ==========
    
    1. Configure kubectl:
       ${local.configure_kubectl_cmd}
    
    2. Verify cluster:
       kubectl get nodes
       kubectl get pods --all-namespaces
    
    3. Check services:
       kubectl get svc -n default
    
    4. Access the API:
       Bird API: ${try(kubernetes_service.bird_api[0].status[0].load_balancer[0].ingress[0].hostname, "Pending (check after 2-3 minutes)")}
       Bird Image API: ${try(kubernetes_service.bird_image_api[0].status[0].load_balancer[0].ingress[0].hostname, "Pending (check after 2-3 minutes)")}
    
    5. For monitoring, dashboards, and logs:
       See: terraform output -json | grep cloudwatch
    
    ===================================================
    
  EOT
}

# Local reference for quick start
locals {
  configure_kubectl_cmd = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}"
}
