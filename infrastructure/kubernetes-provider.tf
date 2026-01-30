# ============================================================================
# Bird API Deployment
# ============================================================================

resource "kubernetes_deployment" "bird_api" {
  metadata {
    name      = "bird-api"
    namespace = local.namespace
    labels = {
      app = "bird-api"
    }
  }

  spec {
    replicas = var.bird_api_replicas

    selector {
      match_labels = {
        app = "bird-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "bird-api"
        }
        annotations = local.common_annotations
      }

      spec {
        container {
          name  = "bird-api"
          image = var.bird_api_image
          port {
            container_port = var.bird_api_port
            protocol       = "TCP"
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }

          liveness_probe {
            http_get {
              path   = "/health"
              port   = var.bird_api_port
              scheme = "HTTP"
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path   = "/health"
              port   = var.bird_api_port
              scheme = "HTTP"
            }
            initial_delay_seconds = 10
            period_seconds        = 5
            timeout_seconds       = 3
            failure_threshold     = 2
          }
        }

        restart_policy = "Always"
      }
    }
  }

  depends_on = [aws_eks_node_group.main]
}

# ============================================================================
# Bird API Service (LoadBalancer)
# ============================================================================

resource "kubernetes_service" "bird_api" {
  count = var.enable_alb ? 1 : 0

  metadata {
    name      = "bird-api-service"
    namespace = local.namespace
    labels = {
      app = "bird-api"
    }
  }

  spec {
    type = "LoadBalancer"

    selector = {
      app = "bird-api"
    }

    port {
      port        = 80
      target_port = var.bird_api_port
      protocol    = "TCP"
    }
  }

  depends_on = [kubernetes_deployment.bird_api]
}

# ============================================================================
# Bird API HPA
# ============================================================================

resource "kubernetes_horizontal_pod_autoscaler" "bird_api" {
  count = var.hpa_enabled ? 1 : 0

  metadata {
    name      = "bird-api-hpa"
    namespace = local.namespace
  }

  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.bird_api.metadata[0].name
    }

    min_replicas = var.hpa_min_replicas
    max_replicas = var.hpa_max_replicas

    target_cpu_utilization_percentage = var.hpa_target_cpu_utilization
  }

  depends_on = [kubernetes_deployment.bird_api]
}

# ============================================================================
# Bird Image API Deployment
# ============================================================================

resource "kubernetes_deployment" "bird_image_api" {
  metadata {
    name      = "bird-image-api"
    namespace = local.namespace
    labels = {
      app = "bird-image-api"
    }
  }

  spec {
    replicas = var.bird_image_api_replicas

    selector {
      match_labels = {
        app = "bird-image-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "bird-image-api"
        }
        annotations = local.common_annotations
      }

      spec {
        container {
          name  = "bird-image-api"
          image = var.bird_image_api_image
          port {
            container_port = var.bird_image_api_port
            protocol       = "TCP"
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }

          liveness_probe {
            http_get {
              path   = "/health"
              port   = var.bird_image_api_port
              scheme = "HTTP"
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path   = "/health"
              port   = var.bird_image_api_port
              scheme = "HTTP"
            }
            initial_delay_seconds = 10
            period_seconds        = 5
            timeout_seconds       = 3
            failure_threshold     = 2
          }
        }

        restart_policy = "Always"
      }
    }
  }

  depends_on = [aws_eks_node_group.main]
}

# ============================================================================
# Bird Image API Service (LoadBalancer)
# ============================================================================

resource "kubernetes_service" "bird_image_api" {
  count = var.enable_alb ? 1 : 0

  metadata {
    name      = "bird-image-api-service"
    namespace = local.namespace
    labels = {
      app = "bird-image-api"
    }
  }

  spec {
    type = "LoadBalancer"

    selector = {
      app = "bird-image-api"
    }

    port {
      port        = 80
      target_port = var.bird_image_api_port
      protocol    = "TCP"
    }
  }

  depends_on = [kubernetes_deployment.bird_image_api]
}

# ============================================================================
# Bird Image API HPA
# ============================================================================

resource "kubernetes_horizontal_pod_autoscaler" "bird_image_api" {
  count = var.hpa_enabled ? 1 : 0

  metadata {
    name      = "bird-image-api-hpa"
    namespace = local.namespace
  }

  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.bird_image_api.metadata[0].name
    }

    min_replicas = var.hpa_min_replicas
    max_replicas = var.hpa_max_replicas

    target_cpu_utilization_percentage = var.hpa_target_cpu_utilization
  }

  depends_on = [kubernetes_deployment.bird_image_api]
}

# ============================================================================
# Bird Frontend Deployment
# ============================================================================

resource "kubernetes_deployment" "bird_frontend" {
  metadata {
    name      = "bird-frontend"
    namespace = local.namespace
    labels = {
      app = "bird-frontend"
    }
  }

  spec {
    replicas = var.bird_frontend_replicas

    selector {
      match_labels = {
        app = "bird-frontend"
      }
    }

    template {
      metadata {
        labels = {
          app = "bird-frontend"
        }
        annotations = local.common_annotations
      }

      spec {
        container {
          name  = "bird-frontend"
          image = var.bird_frontend_image
          port {
            container_port = var.bird_frontend_port
            protocol       = "TCP"
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }

          liveness_probe {
            http_get {
              path   = "/"
              port   = var.bird_frontend_port
              scheme = "HTTP"
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path   = "/"
              port   = var.bird_frontend_port
              scheme = "HTTP"
            }
            initial_delay_seconds = 10
            period_seconds        = 5
            timeout_seconds       = 3
            failure_threshold     = 2
          }
        }

        restart_policy = "Always"
      }
    }
  }

  depends_on = [aws_eks_node_group.main]
}

# ============================================================================
# Bird Frontend Service (LoadBalancer)
# ============================================================================

resource "kubernetes_service" "bird_frontend" {
  count = var.enable_alb ? 1 : 0

  metadata {
    name      = "bird-frontend-service"
    namespace = local.namespace
    labels = {
      app = "bird-frontend"
    }
  }

  spec {
    type = "LoadBalancer"

    selector = {
      app = "bird-frontend"
    }

    port {
      port        = 80
      target_port = var.bird_frontend_port
      protocol    = "TCP"
    }
  }

  depends_on = [kubernetes_deployment.bird_frontend]
}

# ============================================================================
# Bird Frontend HPA
# ============================================================================

resource "kubernetes_horizontal_pod_autoscaler" "bird_frontend" {
  count = var.hpa_enabled ? 1 : 0

  metadata {
    name      = "bird-frontend-hpa"
    namespace = local.namespace
  }

  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.bird_frontend.metadata[0].name
    }

    min_replicas = var.hpa_min_replicas
    max_replicas = var.hpa_max_replicas

    target_cpu_utilization_percentage = var.hpa_target_cpu_utilization
  }

  depends_on = [kubernetes_deployment.bird_frontend]
}

# ============================================================================
# Pod Disruption Budget for High Availability - Bird API
# ============================================================================

resource "kubernetes_pod_disruption_budget_v1" "bird_api" {
  metadata {
    name      = "bird-api-pdb"
    namespace = local.namespace
  }

  spec {
    min_available = 1

    selector {
      match_labels = {
        app = "bird-api"
      }
    }
  }

  depends_on = [kubernetes_deployment.bird_api]
}

# ============================================================================
# Pod Disruption Budget for High Availability - Bird Image API
# ============================================================================

resource "kubernetes_pod_disruption_budget_v1" "bird_image_api" {
  metadata {
    name      = "bird-image-api-pdb"
    namespace = local.namespace
  }

  spec {
    min_available = 1

    selector {
      match_labels = {
        app = "bird-image-api"
      }
    }
  }

  depends_on = [kubernetes_deployment.bird_image_api]
}

# ============================================================================
# Pod Disruption Budget for High Availability - Bird Frontend
# ============================================================================

resource "kubernetes_pod_disruption_budget_v1" "bird_frontend" {
  metadata {
    name      = "bird-frontend-pdb"
    namespace = local.namespace
  }

  spec {
    min_available = 1

    selector {
      match_labels = {
        app = "bird-frontend"
      }
    }
  }

  depends_on = [kubernetes_deployment.bird_frontend]
}