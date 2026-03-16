data "aws_caller_identity" "current" {}

resource "aws_ecs_cluster" "dotohtwo_cluster" {
  name = var.cluster_name
}

resource "aws_ecs_capacity_provider" "dotohtwo_capacityprovider" {
  name = "dotohtwo-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = var.dotohtwo_asg_arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 100
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 100
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "dotohtwo_cluster_capacityproviders" {
  cluster_name = aws_ecs_cluster.dotohtwo_cluster.name

  capacity_providers = [aws_ecs_capacity_provider.dotohtwo_capacityprovider.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.dotohtwo_capacityprovider.name
    base              = 1
    weight            = 100
  }
}

resource "aws_ecs_task_definition" "dotohtwo_taskdefinition" {
  family                = "dotohtwo-api"
  network_mode          = "awsvpc"
  execution_role_arn    = var.execution_role_arn
  task_role_arn         = var.task_role_arn
  cpu                   = 512
  memory                = 512
  requires_compatibilities = ["EC2"]

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name      = "dotohtwo-api"
      image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com/dotohtwo-api:latest"
      cpu       = 512
      memory    = 512
      essential = true

      environment = [
        { name = "ENVIRONMENT",            value = "dev" },
        { name = "LOG_LEVEL",              value = "info" },
        { name = "SPRING_DATASOURCE_URL",  value = "jdbc:postgresql://${var.db_endpoint}/postgres" },
        { name = "SPRING_DATASOURCE_USERNAME",        value = "postgres" },
        { name = "SPRING_CASSANDRA_CONTACT_POINTS",   value = "cassandra.us-east-1.amazonaws.com" },
        { name = "SPRING_CASSANDRA_PORT",             value = "9142" },
        { name = "SPRING_CASSANDRA_KEYSPACE_NAME",    value = var.keyspace_name },
        { name = "SPRING_CASSANDRA_LOCAL_DATACENTER", value = "us-east-1" },
        { name = "SPRING_CASSANDRA_SSL_ENABLED",      value = "true" }
      ]

      secrets = [
        {
          name      = "SPRING_DATASOURCE_PASSWORD"
          valueFrom = var.db_secret_arn
        }
      ]

      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/dotohtwo-api"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group"  = "true"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "dotohtwo_review_ingestor_taskdefinition" {
  family                   = "dotohtwo-review-ingestor"
  network_mode             = "awsvpc"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  cpu                      = 256
  memory                   = 256
  requires_compatibilities = ["EC2"]

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name      = "dotohtwo-review-ingestor"
      image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com/dotohtwo-review-ingestor:latest"
      cpu       = 256
      memory    = 256
      essential = true

      environment = [
        { name = "ENVIRONMENT",                           value = "dev" },
        { name = "LOG_LEVEL",                             value = "info" },
        { name = "SPRING_CASSANDRA_CONTACT_POINTS",       value = "cassandra.us-east-1.amazonaws.com" },
        { name = "SPRING_CASSANDRA_PORT",                 value = "9142" },
        { name = "SPRING_CASSANDRA_KEYSPACE_NAME",        value = var.keyspace_name },
        { name = "SPRING_CASSANDRA_LOCAL_DATACENTER",     value = "us-east-1" },
        { name = "SPRING_CASSANDRA_SSL_ENABLED",          value = "true" }
      ]

      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/dotohtwo-review-ingestor"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group"  = "true"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "dotohtwo_review_ingestor_service" {
  name                              = "dotohtwo-review-ingestor-service"
  cluster                           = aws_ecs_cluster.dotohtwo_cluster.id
  task_definition                   = aws_ecs_task_definition.dotohtwo_review_ingestor_taskdefinition.arn
  desired_count                     = 1
  health_check_grace_period_seconds = 180

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.dotohtwo_capacityprovider.name
    weight            = 100
    base              = 0
  }

  force_new_deployment = true

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.ecs_tasks_security_group_id]
  }

  load_balancer {
    target_group_arn = var.review_ingestor_targetgroup_arn
    container_name   = "dotohtwo-review-ingestor"
    container_port   = 8080
  }
}

resource "aws_ecs_service" "dotohtwo_service" {
  name                               = "dotohtwo-service"
  cluster                            = aws_ecs_cluster.dotohtwo_cluster.id
  task_definition                    = aws_ecs_task_definition.dotohtwo_taskdefinition.arn
  desired_count                      = 1
  health_check_grace_period_seconds  = 180

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.dotohtwo_capacityprovider.name
    weight            = 100
    base              = 1
  }

  force_new_deployment = true

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.ecs_tasks_security_group_id]
  }

  load_balancer {
    target_group_arn = var.dotohtwo_targetgroup_arn
    container_name   = "dotohtwo-api"
    container_port   = 8080
  }
}
