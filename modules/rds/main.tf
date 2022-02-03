resource "aws_db_subnet_group" "rdssubnet" {
  name       = "${var.app_name}-${var.environment}-db-subnet"
  subnet_ids = var.subnets
}

resource "aws_db_instance" "default" {
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "12.9"
  instance_class         = "db.t2.micro"
  name                   = "postgresdb"
  username               = "rootuser"
  password               = random_password.password.result
  skip_final_snapshot    = true
  multi_az               = false
  db_subnet_group_name   = aws_db_subnet_group.rdssubnet.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}

resource "aws_security_group" "rds_sg" {
  name   = "rds-vpc"
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

resource "random_password" "password" {
  length = 16
}
