locals {
  environment = "dev"
  app_name = "tg-bot-vstup"
  aws_region = "eu-central-1"
  availability_zones_count = 2
  app_port = 5000
  app_count = 1
  health_check_path = "/"
  source_repo_url = "https://github.com/tg-bot-vstup/application"
  infra_repo_url = "https://github.com/tg-bot-vstup/infrastructure"
  codebuild_branch_filter = "^refs/heads/parser$"
}

inputs = {
  environment = local.environment
  app_name = local.app_name
  aws_region = local.aws_region
  availability_zones_count = local.availability_zones_count
  app_port = local.app_port
  app_count = local.app_count
  health_check_path = local.health_check_path
  source_repo_url = local.source_repo_url
  infra_repo_url = local.infra_repo_url
  codebuild_branch_filter = local.codebuild_branch_filter
}

generate "terraform_config" {
  path = "terraform.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "aws" {
  region = "${local.aws_region}"
}

terraform {
  backend "s3" {}
}
EOF
}

remote_state {
  backend = "s3"
  config = {
    bucket         = format("%s-%s-%s-%s", "terraform", local.app_name, local.environment, local.aws_region)
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    encrypt        = true
    dynamodb_table = format("lock-%s-%s-%s", local.app_name, local.environment, local.aws_region)
  }
}
