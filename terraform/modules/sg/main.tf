# Terraform module for defining security groups

# Security Group for EC2 instance, allowing SSH and HTTP access
resource "aws_security_group" "ec2_sg" {
  vpc_id = var.vpc_id # VPC where the security group will be created

  # Allow SSH access from any IP (change for better security)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Consider restricting to specific IP
  }

  # Allow HTTP access from any IP (for web traffic)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-security-group"
  }
}

# Security Group for RDS database, allowing access only from EC2
resource "aws_security_group" "rds_sg" {
  vpc_id = var.vpc_id

  # Allow MySQL (3306) access only from EC2 instance
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id] # Restrict access to EC2 only
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-security-group"
  }
}

# Security Group for Redis, allowing access only from EC2
resource "aws_security_group" "redis_sg" {
  vpc_id = var.vpc_id

  # Allow Redis (6379) access only from EC2 instance
  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id] # Restrict access to EC2 only
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "redis-security-group"
  }
}

# Security Group for ALB
resource "aws_security_group" "alb_sg" {
  vpc_id = var.vpc_id # The VPC where this security group will be created

  # Allow incoming HTTP traffic on port 80 from any IP address
  ingress {
    from_port   = 80            # HTTP port
    to_port     = 80            # HTTP port
    protocol    = "tcp"         # Use TCP protocol
    cidr_blocks = ["0.0.0.0/0"] # Open access to all IP addresses (not recommended for production)
  }

  # Allow all outbound traffic to ensure ALB can communicate with backend services (e.g., EC2 instances)
  egress {
    from_port   = 0             # Allow all ports
    to_port     = 0             # Allow all ports
    protocol    = "-1"          # Allow all protocols
    cidr_blocks = ["0.0.0.0/0"] # Open access to all destinations
  }

  tags = {
    Name = "alb-security-group" # Tag for easier identification
  }
}