resource "aws_db_subnet_group" "rdssubnet" {
  name       = "${var.app_name}-${var.environment}-db-subnet"
  subnet_ids = var.subnets
}

resource "aws_db_instance" "default" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "12.9"
  instance_class       = "db.t2.micro"
  name                 = "postgresdb"
  username             = "rootuser"
  password             = random_password.password.result
  skip_final_snapshot  = true
  multi_az             = false
  db_subnet_group_name = aws_db_subnet_group.rdssubnet.name
}

resource "random_password" "password" {
  length  = 16
  special = true
}
