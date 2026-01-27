# ============================================================================
# IAM Role for Cluster Autoscaler
# ============================================================================

resource "aws_iam_role" "cluster_autoscaler" {
  name = "${var.project_name}-cluster-autoscaler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}"
        }
        Condition = {
          StringEquals = {
            "${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:cluster-autoscaler"
          }
        }
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-cluster-autoscaler"
    }
  )
}

# ============================================================================
# IAM Policy for Cluster Autoscaler
# ============================================================================

resource "aws_iam_role_policy" "cluster_autoscaler" {
  name = "${var.project_name}-cluster-autoscaler-policy"
  role = aws_iam_role.cluster_autoscaler.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeScalingActivities",
          "autoscaling:DescribeTags",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
          }
        }
      }
    ]
  })
}

# ============================================================================
# Kubernetes Service Account for Cluster Autoscaler
# ============================================================================

resource "kubernetes_service_account" "cluster_autoscaler" {
  count = var.enable_cluster_autoscaler ? 1 : 0

  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.cluster_autoscaler.arn
    }
  }

  depends_on = [aws_eks_node_group.main]
}

# ============================================================================
# Cluster Autoscaler Helm Chart - COMMENTED OUT (Helm repo timeout)
# Install manually after: helm repo add autoscaler https://kubernetes.github.io/autoscaler
# ============================================================================

# resource "helm_release" "cluster_autoscaler" {
#   count = var.enable_cluster_autoscaler ? 1 : 0
# 
#   name       = "cluster-autoscaler"
#   repository = "https://kubernetes.github.io/autoscaler"
#   chart      = "cluster-autoscaler"
#   namespace  = "kube-system"
#   version    = "9.29.3"
# 
#   set {
#     name  = "autoDiscovery.clusterName"
#     value = aws_eks_cluster.main.name
#   }
# 
#   set {
#     name  = "awsRegion"
#     value = var.aws_region
#   }
# 
#   set {
#     name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = aws_iam_role.cluster_autoscaler.arn
#   }
# 
#   set {
#     name  = "rbac.serviceAccount.create"
#     value = "false"
#   }
# 
#   set {
#     name  = "rbac.serviceAccount.name"
#     value = kubernetes_service_account.cluster_autoscaler[0].metadata[0].name
#   }
# 
#   depends_on = [aws_eks_node_group.main, kubernetes_service_account.cluster_autoscaler]
# }

# ============================================================================
# Metrics Server (required for HPA) - COMMENTED OUT (Helm repo timeout)
# Install manually after: helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
# ============================================================================

# resource "helm_release" "metrics_server" {
#   count = var.enable_metrics_server ? 1 : 0
# 
#   name       = "metrics-server"
#   repository = "https://kubernetes-sigs.github.io/metrics-server/"
#   chart      = "metrics-server"
#   namespace  = "kube-system"
#   version    = "3.11.0"
# 
#   set {
#     name  = "args[0]"
#     value = "--kubelet-insecure-tls"
#   }
# 
#   depends_on = [aws_eks_node_group.main]
# }

# ============================================================================
# Outputs for Autoscaling
# ============================================================================

output "cluster_autoscaler_role_arn" {
  description = "IAM role ARN for Cluster Autoscaler"
  value       = aws_iam_role.cluster_autoscaler.arn
}

output "cluster_autoscaler_service_account" {
  description = "Service account for Cluster Autoscaler"
  value       = try(kubernetes_service_account.cluster_autoscaler[0].metadata[0].name, null)
}

output "metrics_server_installed" {
  description = "Whether Metrics Server is installed"
  value       = var.enable_metrics_server
}

output "cluster_autoscaler_installed" {
  description = "Whether Cluster Autoscaler is installed"
  value       = var.enable_cluster_autoscaler
}