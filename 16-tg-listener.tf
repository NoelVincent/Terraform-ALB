#########################
# Default Action
#########################


resource "aws_lb_listener" "listner" {
  
  load_balancer_arn = aws_lb.alb.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = " No such Site Found"
      status_code  = "200"
   }
}
}


##################################################
# Forwording rule - one
#
# Considering hostname as blog-one.com
###################################################
resource "aws_lb_listener_rule" "rule-one" {

  listener_arn = aws_lb_listener.listner.id
  priority     = 5

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-one.arn
  }

  condition {
    host_header {
      values = ["blog-one.com"]
    }
  }
}


##################################################
# Forwording rule - two
#
# Considering hostname as blog-two.com
###################################################
resource "aws_lb_listener_rule" "rule-two" {

  listener_arn = aws_lb_listener.listner.id
  priority     = 6

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-two.arn
  }

  condition {
    host_header {
      values = ["blog-two.com"]
    }
  }
}
