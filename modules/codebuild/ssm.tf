resource "aws_ssm_parameter" "bot_token" {
  name  = "bot_token"
  type  = "SecureString"
  value = var.bot_token
  tier  = "Standard"
}

# TODO: db password
resource "aws_ssm_parameter" "db_url" {
  name  = "db_url"
  type  = "SecureString"
  value = var.db_url
  tier  = "Standard"
}
