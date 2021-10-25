############################
# Applcation load balancer 
############################

resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.all-traffic.id]
  subnets            = [aws_subnet.public1.id, aws_subnet.public2.id]
  enable_deletion_protection = false
  depends_on = [ aws_lb_target_group.tg-one ]
  tags = {
     Name = "${var.project}-alb"
   }
}

output "alb-dns-name" {
  value = aws_lb.alb.dns_name
} 
