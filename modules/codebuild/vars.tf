variable "app_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "source_repo_url" {
  type = string
}

variable "infra_repo_url" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "codebuild_branch_filter" {
  type = string
}

variable "github_token" {
  type      = string
  sensitive = true
}

variable "bot_token" {
  type      = string
  sensitive = true
}

variable "db_url" {
  type      = string
  sensitive = true
}
