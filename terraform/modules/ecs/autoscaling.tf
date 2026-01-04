resource "aws_appautoscaling_target" "ecs_service" {
  service_namespace  = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"

  # format requis: service/<clusterName>/<serviceName>
  resource_id = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.this.name}"

  min_capacity = var.autoscaling_min
  max_capacity = var.autoscaling_max
}

resource "aws_appautoscaling_policy" "cpu_target" {
  name               = "${var.project}-${var.environment}-cpu-target"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = aws_appautoscaling_target.ecs_service.service_namespace
  scalable_dimension = aws_appautoscaling_target.ecs_service.scalable_dimension
  resource_id        = aws_appautoscaling_target.ecs_service.resource_id

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.autoscaling_cpu_target
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}
