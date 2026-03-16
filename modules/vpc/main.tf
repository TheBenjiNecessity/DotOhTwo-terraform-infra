resource "aws_vpc" "dotohtwo_vpc_1" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = true
    tags = {
        organization = "DotOhTwo"
        name = "dotohtwo_vpc_1"
    }
}

resource "aws_subnet" "subnet" {
    vpc_id                  = aws_vpc.dotohtwo_vpc_1.id
    cidr_block              = cidrsubnet(aws_vpc.dotohtwo_vpc_1.cidr_block, 8, 1)
    map_public_ip_on_launch = true
    availability_zone       = "us-east-1a"
    depends_on = [
        aws_vpc.dotohtwo_vpc_1
    ]
}

resource "aws_subnet" "subnet2" {
    vpc_id                  = aws_vpc.dotohtwo_vpc_1.id
    cidr_block              = cidrsubnet(aws_vpc.dotohtwo_vpc_1.cidr_block, 8, 2)
    map_public_ip_on_launch = true
    availability_zone       = "us-east-1b"
    depends_on = [
        aws_vpc.dotohtwo_vpc_1
    ]
}

resource "aws_route_table" "route_table" {
    vpc_id = aws_vpc.dotohtwo_vpc_1.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet_gateway.id
    }
    depends_on = [
        aws_vpc.dotohtwo_vpc_1
    ]
}

resource "aws_route_table_association" "subnet_route" {
    subnet_id      = aws_subnet.subnet.id
    route_table_id = aws_route_table.route_table.id
    depends_on = [
        aws_vpc.dotohtwo_vpc_1,
        aws_route_table.route_table,
        aws_subnet.subnet
    ]
}

resource "aws_route_table_association" "subnet2_route" {
    subnet_id      = aws_subnet.subnet2.id
    route_table_id = aws_route_table.route_table.id
    depends_on = [
        aws_vpc.dotohtwo_vpc_1,
        aws_route_table.route_table,
        aws_subnet.subnet2
    ]
}

resource "aws_internet_gateway" "internet_gateway" {
    vpc_id = aws_vpc.dotohtwo_vpc_1.id
    tags = {
        organization = "DotOhTwo"
        name = "internet_gateway"
    }
    depends_on = [
        aws_vpc.dotohtwo_vpc_1,
        aws_subnet.subnet,
        aws_subnet.subnet2
    ]

    timeouts {
      delete = "20m"
    }
}

resource "aws_security_group" "alb" {
  name        = "dotohtwo-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.dotohtwo_vpc_1.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from internet"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name = "dotohtwo-alb-sg"
  }
}

data "aws_ip_ranges" "ec2_instance_connect" {
  regions  = ["us-east-1"]
  services = ["EC2_INSTANCE_CONNECT"]
}

resource "aws_security_group" "ecs_instances" {
  name        = "dotohtwo-ecs-instances-sg"
  description = "Security group for ECS EC2 instances"
  vpc_id      = aws_vpc.dotohtwo_vpc_1.id

  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    description     = "Allow all TCP from ALB SG reference"
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.dotohtwo_vpc_1.cidr_block]
    description = "Allow health checks from within the VPC (ALB nodes)"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = data.aws_ip_ranges.ec2_instance_connect.cidr_blocks
    description = "Allow SSH from EC2 Instance Connect"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name = "dotohtwo-ecs-instances-sg"
  }
}