# Creating a Application Load Balancer using Terraform
Here, I am creating a VPC first with 3 public subnets along with Internet Gateway and a Public Route Table. Then will be creating a Lauch Configuration, Target group, Auto Scaling Group (2 each) and an Application Load Balancer.

## Terraform
Terraform is an open-source infrastructure as code software tool that provides a consistent CLI workflow to manage hundreds of cloud services. Terraform codifies cloud APIs into declarative configuration files.
https://www.terraform.io/

## Installing Terraform
- Create an IAM user on your AWS console and give access to create the required resources.
- Create a directory where you can create terraform configuration files.
- Download Terrafom, click here [Terraform](https://www.terraform.io/downloads.html).
- Install Terraform, click here [Terraform installation](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started)

##### Command to install Terraform
```sh
# wget https://releases.hashicorp.com/terraform/1.0.8/terraform_1.0.8_linux_amd64.zip
# unzip terraform_1.0.8_linux_amd64.zip
# mv terraform /usr/local/bin/

# terraform version   =======> To check the version
Terraform v1.0.8
on linux_amd64
```

> Note : The terrafom files must be created with .tf extension as terraform can only execute .tf files
> https://www.terraform.io/docs/language/files/index.html

### Terraform commands

#### Terraform Validation
> This will check for any errors on the source code

```sh
terraform validate
```
#### Terraform Plan
> The terraform plan command provides a preview of the actions that Terraform will take in order to configure resources per the configuration file. 

```sh
terraform plan
```
#### Terraform apply
> This will execute the tf file that we created

```sh
terraform apply
```
https://www.terraform.io/docs/cli/commands/index.html

## 1. Declaring Variables
This is used to declare the variable and pass values to terraform source code.
```sh
vim variable.tf
```
##### Declare the variables for initialising terraform
```sh
variable "project" {
  default = "test"
}
variable "access_key"{
  default = " "           #==========> provide the access_key of the IAM user
}
variable "secret_key"{
  default = " "          #==========> provide the secret_key of the IAM user
}
variable "vpc_cidr" {
  default = "172.16.0.0/16"
}
variable "vpc_subnets" {
  default = "3"
}
variable "type" {
  description = "Instance type"    
  default = "t2.micro"
}
variable "ami" {
  description = "amazon linux 2 ami"
  default = "ami-041d6256ed0f2061c"
}
variable "asg_count" {
	  default = 2
}
```
##### Creating a variable.tfvars
> Note : A terraform.tfvars file is used to set the actual values of the variables.
```sh
vim variable.tfvars
```
```sh
project     = " Your project name"
access_key  = "IAM user access_key"
secret_key  = "IAM user secret_key"
vpc_cidr    = "VPC cidr block"
```

## 2.  Create the provider file
> Terraform configurations must declare which providers they require, so that Terraform can install and use them. I'm using AWS as provider
```sh
vim provider.tf
```
```sh
provider "aws" {
  region     = "ap-south-1"
  access_key = var.access_key
  secret_key = var.secret_key
}
```

## 3. Fetching Availability Zones in working AWS region
> This will fetch all available Availability Zones in working AWS region and store the details in variable az
```sh
vim az.tf
```
```sh
data "aws_availability_zones" "az" {
  state = "available"
}

output "availability_names" {    
  value = data.aws_availability_zones.az.names
}
```
> I have also added output in this file so that I could get an ouput when I run the command
```sh
terrafrom output
```
https://www.terraform.io/docs/cli/commands/output.html

## 4. Creating VPC
- Create VPC resource
```sh
vim vpc.tf
```
```sh
resource "aws_vpc" "vpc" {
    
  cidr_block            =  var.vpc_cidr
  instance_tenancy      = "default"
  enable_dns_hostnames  = true
  enable_dns_support    = true
  tags = {
    Name = "${var.project}-vpc"
    Project = var.project
  }
    
  lifecycle {
    create_before_destroy = false
  }
}
```
## 5. Creating and Attaching Internet GateWay
```sh
vim igw.tf
```
```sh
resource "aws_internet_gateway" "igw" {
    
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.project}-igw"
    Project = var.project
  }
    
  lifecycle {
    create_before_destroy = false
  }
}
```

## 6. Creating Public subents
```sh
vim subnet.tf
```
```sh
###################################################################
# Creating Public Subnet1
###################################################################

resource "aws_subnet" "public1" {
    
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr,var.vpc_subnets, 0)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.az.names[0]
  tags = {
    Name = "${var.project}-public1"
    Project = var.project
  }
  lifecycle {
    create_before_destroy = false
  }
}

###################################################################
# Creating Public Subnet2
###################################################################

resource "aws_subnet" "public2" {
    
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr,var.vpc_subnets, 1)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.az.names[1]
  tags = {
    Name = "${var.project}-public2"
    Project = var.project
  }
    
  lifecycle {
    create_before_destroy = false
  }
}

###################################################################
# Creating Public Subnet3
###################################################################

resource "aws_subnet" "public3" {
    
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr,var.vpc_subnets,2)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.az.names[2]
  tags = {
    Name = "${var.project}-public3"
    Project = var.project
  }
  lifecycle {
    create_before_destroy = false
  }
}
```
## 7. Creating Public Route Table
```sh
resource "aws_route_table" "public" {
    
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.project}-public-rtb"
    Project = var.project
  }
}
```

## 8. Route Table Association
```sh
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public3" {
  subnet_id      = aws_subnet.public3.id
  route_table_id = aws_route_table.public.id
}
```
## 9. Creating Security Group
```sh
resource "aws_security_group" "all-traffic" {
    
  vpc_id      = aws_vpc.vpc.id
  name        = "${var.project}-all-traffic"
  description = "allow all ports"

  ingress = [
           { 
      description      = ""
      prefix_list_ids  = []
      security_groups  = []
      self             = false
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  ]

  egress = [
     { 
      description      = ""
      prefix_list_ids  = []
      security_groups  = []
      self             = false
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  ]

  tags = {
    Name = "${var.project}-all-traffic"
    Project = var.project
  }
  lifecycle {
    create_before_destroy = true
  }
}
```
- Allows all traffic from anywhere.

# 10. Creating a key pair
- First generate a key using the following command and enter a file in which to save the key
```sh
ssh-keygen
```
> Here, I used the file name as terraform
```sh
resource "aws_key_pair" "key" {
  key_name   = "${var.project}-key"
  public_key = file("terraform.pub")
  tags = {
    Name = "${var.project}-key"
    Project = var.project
  }
}
```

# 11. Creating a Application Load Balancer
> A load balancer serves as the single point of contact for clients. The load balancer distributes incoming application traffic across multiple targets, such as EC2 instances, in multiple Availability Zones.

The following diagram illustrates the basic components.

![alt text](https://i.ibb.co/r33pSXG/Inked2-LI.jpg)

| Concept | Description |
| --- | --- |
| Listeners | A Listener is a process that checks for connection requests, using the protocol and port that you configure. The rules that you define for a listener determine how the load balancer routes requests to the target in one or more target groups|
|Target | A target is a destination for traffic based on the established listener rules.|
| Target Group | Each target group routes requests to one or more registered targets using the protocol and port number specified. A target can be registered with multiple target groups. Health checks can be configured on a per target group basis. |

> After the load balancer receives a request, it evaluates the listener rules in priority order to determine which rule to apply, and then selects a target from the target group for the rule action.

##### Creating the Application Load Balancer
```sh
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
```

# 12. Creating Launch Configuration
##### Creating two user data for launch configuration first.

```sh
#######################
# First User Data
#######################
#!/bin/bash

echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config
echo "LANG=en_US.utf-8" >> /etc/environment
echo "LC_ALL=en_US.utf-8" >> /etc/environment
service sshd restart

echo "password123" | passwd root --stdin
sed  -i 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
service sshd restart

yum install httpd php -y
systemctl enable httpd
systemctl restart httpd

cat <<EOF > /var/www/html/index.php
<?php
\$output = shell_exec('echo $HOSTNAME');
echo "<h1><center><pre>\$output</pre></center></h1>";
echo "<h1><center><pre>  Server 1 </pre></center></h1>";
?>
EOF

#######################
# Second User Data
#######################
#!/bin/bash

echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config
echo "LANG=en_US.utf-8" >> /etc/environment
echo "LC_ALL=en_US.utf-8" >> /etc/environment
service sshd restart

echo "password123" | passwd root --stdin
sed  -i 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
service sshd restart

yum install httpd php -y
systemctl enable httpd
systemctl restart httpd

cat <<EOF > /var/www/html/index.php
<?php
\$output = shell_exec('echo $HOSTNAME');
echo "<h1><center><pre>\$output</pre></center></h1>";
echo "<h1><center><pre>  Server 2 </pre></center></h1>";
?>
EOF
```

##### Launch Configuration
```sh
#######################################################
# First Launch Configuration
#######################################################

resource "aws_launch_configuration" "LC-one" {
  
  name              = "LC1"
  image_id          = var.ami
  instance_type     = var.type
  key_name          = aws_key_pair.key.id
  security_groups   = [aws_security_group.all-traffic.id]
  user_data         = file("11-setup.sh")                #==========> First User Data File
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
  user_data         = file("12-setup.sh")              #==========> Second User Data File
  lifecycle {
    create_before_destroy = true
  }
}
```

# 13. Creating Target Group and Listeners
> Creating 2 target group so that we can forward the traffic
```sh
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
```
##### ALB - http listener - default action
```sh
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
```
##### ALB - http listener - Adding Rules
```sh
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
```

# 14. Creating Auto Scale Group
```sh
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
```

# Conclusion
Here is a simple document on how to use Terraform to build an AWS Application Load Balancer
