# ============================================================================
# SNS Topic for Alerts
# ============================================================================

resource "aws_sns_topic" "alerts" {
  count = var.enable_cloudwatch_monitoring ? 1 : 0
  name  = "${var.project_name}-alerts"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-alerts"
    }
  )
}

# ============================================================================
# SNS Topic Subscription - Email
# ============================================================================

resource "aws_sns_topic_subscription" "alerts_email" {
  count     = var.enable_cloudwatch_monitoring ? 1 : 0
  topic_arn = aws_sns_topic.alerts[0].arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# ============================================================================
# CloudWatch Log Group for Application Logs
# ============================================================================

resource "aws_cloudwatch_log_group" "application_logs" {
  count             = var.enable_cloudwatch_monitoring ? 1 : 0
  name              = "/aws/eks/${var.cluster_name}/applications"
  retention_in_days = var.log_retention_in_days

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-app-logs"
    }
  )
}

# ============================================================================
# CloudWatch Namespace for Custom Metrics
# ============================================================================

locals {
  cloudwatch_namespace = "BirdAPI"
}

# ============================================================================
# CloudWatch Alarms - CPU Utilization
# ============================================================================

resource "aws_cloudwatch_metric_alarm" "pod_cpu_high" {
  count               = var.enable_cloudwatch_monitoring ? 1 : 0
  alarm_name          = "${var.project_name}-pod-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "pod_cpu_utilization"
  namespace           = local.cloudwatch_namespace
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alert when pod CPU utilization is above 80%"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alerts[0].arn]

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-cpu-alarm"
    }
  )
}

# ============================================================================
# CloudWatch Alarms - Memory Utilization
# ============================================================================

resource "aws_cloudwatch_metric_alarm" "pod_memory_high" {
  count               = var.enable_cloudwatch_monitoring ? 1 : 0
  alarm_name          = "${var.project_name}-pod-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "pod_memory_utilization"
  namespace           = local.cloudwatch_namespace
  period              = "300"
  statistic           = "Average"
  threshold           = "85"
  alarm_description   = "Alert when pod memory utilization is above 85%"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alerts[0].arn]

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-memory-alarm"
    }
  )
}

# ============================================================================
# CloudWatch Alarms - Node Status
# ============================================================================

resource "aws_cloudwatch_metric_alarm" "node_not_ready" {
  count               = var.enable_cloudwatch_monitoring ? 1 : 0
  alarm_name          = "${var.project_name}-node-not-ready"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "node_not_ready_count"
  namespace           = local.cloudwatch_namespace
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Alert when a node is not ready"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alerts[0].arn]

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-node-status-alarm"
    }
  )
}

# ============================================================================
# CloudWatch Alarms - Pod Crash Count
# ============================================================================

resource "aws_cloudwatch_metric_alarm" "pod_restarts_high" {
  count               = var.enable_cloudwatch_monitoring ? 1 : 0
  alarm_name          = "${var.project_name}-pod-restarts-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "pod_restart_count"
  namespace           = local.cloudwatch_namespace
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "Alert when pods are restarting frequently"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alerts[0].arn]

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-restart-alarm"
    }
  )
}

# ============================================================================
# CloudWatch Dashboard - Overview
# ============================================================================

resource "aws_cloudwatch_dashboard" "main" {
  count          = var.enable_cloudwatch_monitoring ? 1 : 0
  dashboard_name = "${var.project_name}-overview"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/EKS", "cluster_node_count", { stat = "Average" }],
            [".", "cluster_cpu_utilization", { stat = "Average" }],
            [".", "cluster_memory_utilization", { stat = "Average" }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "EKS Cluster Overview"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            [local.cloudwatch_namespace, "pod_cpu_utilization"],
            [".", "pod_memory_utilization"],
            [".", "pod_restart_count"]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "Pod Metrics"
        }
      }
    ]
  })
}

# ============================================================================
# CloudWatch Log Insights Queries (for documentation)
# ============================================================================

locals {
  cloudwatch_queries = {
    error_logs = "fields @timestamp, @message | filter @message like /ERROR/ | stats count() as error_count"
    
    response_times = "fields @timestamp, response_time | stats avg(response_time), max(response_time), pct(response_time, 95) by bin(1m)"
    
    http_status_distribution = "fields status_code | stats count() as request_count by status_code"
    
    pod_cpu_memory = "fields @timestamp, kubernetes.pod_name, container_cpu_utilization, container_memory_utilization | stats avg(container_cpu_utilization), avg(container_memory_utilization) by kubernetes.pod_name"
  }
}

# ============================================================================
# Outputs for Monitoring
# ============================================================================

output "cloudwatch_log_group_applications" {
  description = "CloudWatch log group for applications"
  value       = try(aws_cloudwatch_log_group.application_logs[0].name, null)
}

output "cloudwatch_dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = try(aws_cloudwatch_dashboard.main[0].dashboard_name, null)
}

output "cloudwatch_namespace" {
  description = "CloudWatch namespace for custom metrics"
  value       = local.cloudwatch_namespace
}

output "sns_topic_arn" {
  description = "SNS topic ARN for alerts"
  value       = try(aws_sns_topic.alerts[0].arn, null)
}

output "cloudwatch_alarms" {
  description = "Created CloudWatch alarms"
  value = {
    cpu_high_alarm     = try(aws_cloudwatch_metric_alarm.pod_cpu_high[0].alarm_name, null)
    memory_high_alarm  = try(aws_cloudwatch_metric_alarm.pod_memory_high[0].alarm_name, null)
    node_not_ready     = try(aws_cloudwatch_metric_alarm.node_not_ready[0].alarm_name, null)
    pod_restarts_high  = try(aws_cloudwatch_metric_alarm.pod_restarts_high[0].alarm_name, null)
  }
}

output "log_insights_queries" {
  description = "CloudWatch Log Insights sample queries"
  value       = local.cloudwatch_queries
}