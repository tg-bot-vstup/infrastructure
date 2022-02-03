// cluster definition
resource "aws_ecs_cluster" "cluster" {
  name = "${var.app_name}-${var.environment}-cluster"
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.app_name}-${var.environment}-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions = jsonencode(
    [
      {
        "name" : "${var.app_name}-${var.environment}-app",
        "image" : format("%s:%s", var.ecr_repo_url, var.image_tag),
        "cpu" : var.fargate_cpu,
        "memory" : var.fargate_memory,
        "networkMode" : "awsvpc",
        "logConfiguration" : {
          "logDriver" : "awslogs",
          "options" : {
            "awslogs-group" : "/ecs/${var.app_name}-${var.environment}",
            "awslogs-region" : "${var.aws_region}",
            "awslogs-stream-prefix" : "ecs"
          }
        },
        "portMappings" : [
          {
            "containerPort" : var.app_port,
            "hostPort" : var.app_port
          }
        ],
        "environment" : [
          {
            "name" : "VERSION",
            "value" : "${var.image_tag}"
          }
        ],
        "secrets" : [
          {
            "name" : "TOKEN",
            "valueFrom" : "${var.bot_token_arn}"
          },
          {
            "name" : "DATABASE_URL",
            "valueFrom" : "${var.db_url_arn}"
          }
        ]
      }
    ]
  )
}

resource "aws_ecs_service" "main" {
  name            = "${var.app_name}-${var.environment}-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = var.subnets
    assign_public_ip = true
  }

  #load_balancer {
  #  target_group_arn = aws_alb_target_group.app.id
  #  container_name   = "${var.app_name}-${var.environment}-app"
  #  container_port   = var.app_port
  #}

  depends_on = [/*aws_alb_listener.front_end,*/ aws_iam_role_policy_attachment.ecs_task_execution_role_policy]
}
