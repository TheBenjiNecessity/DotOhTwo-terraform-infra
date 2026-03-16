data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

resource "aws_launch_template" "dotohtwo_launchtemplate" {
  name_prefix   = "dotohtwo-launch-template-"
  image_id      = data.aws_ssm_parameter.ecs_ami.value
  instance_type = var.instance_type

  vpc_security_group_ids = [var.ecs_instances_security_group_id]

  iam_instance_profile {
    arn = var.instance_profile_arn
  }

  # Register instance with the ECS cluster on boot
  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${var.cluster_name} >> /etc/ecs/ecs.config
    echo ECS_ENABLE_CONTAINER_METADATA=true >> /etc/ecs/ecs.config
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "dotohtwo-ecs-instance"
    }
  }
}

resource "aws_autoscaling_group" "dotohtwo_asg" {
  vpc_zone_identifier = var.subnet_ids
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size

  launch_template {
    id      = aws_launch_template.dotohtwo_launchtemplate.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}

resource "aws_lb" "dotohtwo_loadbalancer" {
  name               = "dotohtwo-loadbalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.subnet_ids

  tags = {
    Name = "dotohtwo-loadbalancer"
  }
}

resource "aws_lb_target_group" "dotohtwo_targetgroup" {
  name        = "dotohtwo-targetgroup"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/actuator/health"
    healthy_threshold   = 2
    unhealthy_threshold = 5
    interval            = 30
    timeout             = 10
    matcher             = "200-299"
  }
}

resource "aws_lb_listener" "dotohtwo_loadbalancer_listener" {
  load_balancer_arn = aws_lb.dotohtwo_loadbalancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dotohtwo_targetgroup.arn
  }
}
