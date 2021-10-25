#######################################################
# First Launch Configuration
#######################################################

resource "aws_launch_configuration" "LC-one" {
  
  name              = "LC1"
  image_id          = var.ami
  instance_type     = var.type
  key_name          = aws_key_pair.key.id
  security_groups   = [aws_security_group.all-traffic.id]
  user_data         = file("11-setup.sh")
  lifecycle {
    create_before_destroy = true
  }
}


#######################################################
# Second Launch Configuration
#######################################################

resource "aws_launch_configuration" "LC-two" {
  
  name              = "LC2"
  image_id          = var.ami
  instance_type     = var.type
  key_name          = aws_key_pair.key.id
  security_groups   = [aws_security_group.all-traffic.id]
  user_data         = file("12-setup.sh")
  lifecycle {
    create_before_destroy = true
  }
}
