resource "aws_launch_template" "app" {
  name_prefix   = "app-tier-"
  image_id      = "ami-0c02fb55956c7d316"
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.app.id]
  user_data               = filebase64("scripts/bootstrap-app.sh")

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "app-tier-instance"
    }
  }
}

resource "aws_autoscaling_group" "app" {
  name                = "app-tier-asg"
  min_size            = 2
  max_size            = 4
  desired_capacity    = 2
  vpc_zone_identifier = aws_subnet.private_app[*].id

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app.arn]

  tag {
    key                 = "Name"
    value               = "app-tier-asg-instance"
    propagate_at_launch = true
  }
}

resource "aws_lb" "main" {
  name               = "three-tier-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id
}

resource "aws_lb_target_group" "app" {
  name     = "app-tier-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 15
    timeout             = 5
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

output "alb_dns_name" {
  value = aws_lb.main.dns_name
}