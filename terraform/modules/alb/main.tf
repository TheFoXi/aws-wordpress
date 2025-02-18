# Define a Target Group for the ALB to route traffic to EC2 instances
# resource "aws_lb_target_group" "wordpress_tg" {
#   name        = "wordpress-tg" # Name of the target group
#   port        = 80             # Port where traffic is routed (HTTP traffic)
#   protocol    = "HTTP"         # HTTP protocol for load balancing
#   vpc_id      = var.vpc_id     # The VPC where the target group operates
#   target_type = "instance"     # Target type is an EC2 instance
#
#   # Health check configuration to monitor instance health
#   health_check {
#     path                = "/" # Health check endpoint
#     interval            = 30  # Time interval between health checks (seconds)
#     timeout             = 5   # Time to wait for a health check response (seconds)
#     healthy_threshold   = 2   # Number of successful checks before an instance is considered healthy
#     unhealthy_threshold = 2   # Number of failed checks before an instance is considered unhealthy
#   }
#
#   tags = {
#     Name = "wordpress-target-group" # Tag for identification
#   }
# }

# Define an Application Load Balancer (ALB) to distribute traffic
# resource "aws_lb" "wordpress_alb" {
#   name               = "wordpress-alb"                                  # Name of the ALB
#   internal           = false                                            # Public-facing ALB
#   load_balancer_type = "application"                                    # ALB type (Layer 7 - HTTP/HTTPS traffic)
#   security_groups    = [var.alb_sg_id]                                  # Attach security group to control access
#   subnets            = [var.public_subnet_1_id, var.public_subnet_2_id] # Subnets where ALB operates
#
#   enable_deletion_protection = false # Disables deletion protection (for testing purposes)
#
#   tags = {
#     Name = "wordpress-alb" # Tag for identification
#   }
# }

# Define an HTTP listener to route requests to the Target Group
# resource "aws_lb_listener" "http" {
#   load_balancer_arn = aws_lb.wordpress_alb.arn # Associate listener with the ALB
#   port              = 80                       # Listen for HTTP traffic on port 80
#   protocol          = "HTTP"                   # HTTP protocol
#
#   default_action {
#     type             = "forward"                            # Forward requests to the target group
#     target_group_arn = aws_lb_target_group.wordpress_tg.arn # Target group where traffic is routed
#   }
# }

# Attach the EC2 instance to the Target Group
# resource "aws_lb_target_group_attachment" "wordpress_target" {
#   target_group_arn = aws_lb_target_group.wordpress_tg.arn # Attach target group
#   target_id        = var.ec2_instance_id                  # ID of the EC2 instance
#   port             = 80                                   # Port the instance listens on
# }


