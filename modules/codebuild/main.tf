resource "aws_codebuild_project" "main" {
  name         = "${var.app_name}-${var.environment}-codebuild-project"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }
  }

  source {
    buildspec = templatefile(
      "${path.module}/buildspec.yml.tpl",
      {
        environment    = "${var.environment}"
        app_name       = "${var.app_name}"
        aws_region     = "${var.aws_region}"
        infra_repo_url = "${var.infra_repo_url}"
        bot_token_arn  = "${aws_ssm_parameter.bot_token.arn}"
        db_url_arn     = "${aws_ssm_parameter.db_url.arn}"
      }
    )
    type            = "GITHUB"
    location        = var.source_repo_url
    git_clone_depth = 1
  }

  vpc_config {
    vpc_id             = var.vpc_id
    subnets            = var.subnets
    security_group_ids = [aws_security_group.codebuild_sg.id]
  }
}

resource "aws_security_group" "codebuild_sg" {
  name   = "codebuild-vpc"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# github hook
resource "aws_codebuild_webhook" "push_hook" {
  project_name = aws_codebuild_project.main.name

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }

    filter {
      type    = "HEAD_REF"
      pattern = var.codebuild_branch_filter
    }
  }

  depends_on = [
    null_resource.connect_github_oauth
  ]
}

resource "null_resource" "connect_github_oauth" {
  triggers = {
    github_token = var.github_token
  }

  provisioner "local-exec" {
    command = <<EOF
aws --region ${var.aws_region} codebuild \
  import-source-credentials \
  --token ${var.github_token} \
  --server-type GITHUB \
  --auth-type PERSONAL_ACCESS_TOKEN
    EOF
  }
}
