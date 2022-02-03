output "db_url" {
  value     = "postgresql://${aws_db_instance.default.username}:${aws_db_instance.default.password}@${aws_db_instance.default.endpoint}"
  sensitive = true
}
