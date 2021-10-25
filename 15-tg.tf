############################
# Target Group One
############################

resource "aws_lb_target_group" "tg-one" {
  name     = "alb-tg-one"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
  load_balancing_algorithm_type = "round_robin"
  deregistration_delay = 60

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    matcher             = 200
    
  }

  lifecycle {
    create_before_destroy = true
  }
}


############################
# Target Group Two
############################

resource "aws_lb_target_group" "tg-two" {
  name     = "alb-tg-two"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
  load_balancing_algorithm_type = "round_robin"
  deregistration_delay = 60

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    matcher             = 200
    
  }

  lifecycle {
    create_before_destroy = true
  }
}
