#######################################################
# First ASG
#######################################################
resource "aws_autoscaling_group" "asg-one" {

  launch_configuration    = aws_launch_configuration.LC-one.id
  vpc_zone_identifier     = [aws_subnet.public1.id, aws_subnet.public2.id]
  health_check_type       = "EC2"
  min_size                = var.asg_count
  max_size                = var.asg_count
  desired_capacity        = var.asg_count
  wait_for_elb_capacity   = var.asg_count
  target_group_arns       = [aws_lb_target_group.tg-one.arn]
  tag {
    key = "Name"
    propagate_at_launch = true
    value = "one-asg"
  }
  lifecycle {
    create_before_destroy = true
  }
}


#######################################################
# Second ASG
#######################################################
resource "aws_autoscaling_group" "asg-two" {

  launch_configuration    = aws_launch_configuration.LC-two.id
  vpc_zone_identifier     = [aws_subnet.public1.id, aws_subnet.public2.id]
  health_check_type       = "EC2"
  min_size                = var.asg_count
  max_size                = var.asg_count
  desired_capacity        = var.asg_count
  wait_for_elb_capacity   = var.asg_count
  target_group_arns       = [aws_lb_target_group.tg-two.arn]
  tag {
    key = "Name"
    propagate_at_launch = true
    value = "two-asg"
  }
  lifecycle {
    create_before_destroy = true
  }
}
