resource "aws_db_subnet_group" "dotohtwo_db_subnet_group" {
  name       = "dotohtwo-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "dotohtwo-db-subnet-group"
  }
}

resource "aws_security_group" "rds" {
  name        = "dotohtwo-rds-sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.ecs_instances_security_group_id]
    description     = "Allow PostgreSQL from ECS tasks"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dotohtwo-rds-sg"
  }
}

resource "aws_db_instance" "dotohtwo_db" {
  identifier        = "dotohtwo-db"
  engine            = "postgres"
  engine_version    = "16"
  instance_class    = var.db_instance_class
  allocated_storage = 20
  storage_type      = "gp2"

  db_name  = "postgres"
  username = "postgres"
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.dotohtwo_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible = false
  skip_final_snapshot = true

  tags = {
    Name = "dotohtwo-db"
  }
}

resource "aws_secretsmanager_secret" "db_password" {
  name = "dotohtwo/db-password"
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = var.db_password
}
