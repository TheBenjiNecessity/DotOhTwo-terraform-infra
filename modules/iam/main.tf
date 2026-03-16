# EC2 instance role - allows ECS agent on EC2 instances to register with the cluster
resource "aws_iam_role" "ecs_ec2_role" {
  name = "dotohtwo-ecsInstanceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_role_attachment" {
  role       = aws_iam_role.ecs_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_ssm" {
  role       = aws_iam_role.ecs_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "dotohtwo-ecsInstanceProfile"
  role = aws_iam_role.ecs_ec2_role.name
}

# ECS task execution role - allows ECS to pull images from ECR and send logs to CloudWatch
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "dotohtwo-ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ecs_task_read_db_secret" {
  name = "dotohtwo-ecs-read-db-secret"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = "arn:aws:secretsmanager:us-east-1:*:secret:dotohtwo/*"
      }
    ]
  })
}

# ECS task role - assumed by the application container at runtime to call AWS services
resource "aws_iam_role" "ecs_task_role" {
  name = "dotohtwo-ecsTaskRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecs_task_keyspaces" {
  name = "dotohtwo-ecs-keyspaces"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cassandra:Select",
          "cassandra:Modify",
          "cassandra:Alter",
          "cassandra:Create",
          "cassandra:Drop",
          "cassandra:TagResource",
          "cassandra:UntagResource"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecs_task_execution_logs" {
  name = "dotohtwo-ecs-create-log-group"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup"]
        Resource = "arn:aws:logs:*:*:log-group:/ecs/*"
      }
    ]
  })
}
