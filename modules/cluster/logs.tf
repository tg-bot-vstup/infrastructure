resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/ecs/${var.app_name}-${var.environment}"
  retention_in_days = 30

  tags = {
    Name = "${var.app_name}-${var.environment}-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "log_stream" {
  name           = "${var.app_name}-${var.environment}-log-stream"
  log_group_name = aws_cloudwatch_log_group.log_group.name
}
