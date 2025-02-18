# Define an EC2 instance for WordPress
resource "aws_instance" "wordpress_ec2" {
  ami                         = var.ec2_ami          # Amazon Machine Image (AMI) for the instance
  instance_type               = var.instance_type    # Instance type (e.g., t2.micro for Free Tier)
  subnet_id                   = var.public_subnet_id # The public subnet where the instance will be launched
  security_groups             = [var.ec2_sg_id]      # Security group to control access
  key_name                    = var.ec2_ssh_key      # SSH key pair for secure access
  associate_public_ip_address = true                 # Assign a public IP for external access

  # lifecycle {
    # ignore_changes = [ vpc_security_group_ids ]
    # prevent_destroy = true
  # }

  tags = {
    Name = "Wordpress" # Tag for easy identification
  }

  # Define the root volume configuration
  root_block_device {
    volume_size           = 8     # Size of the root volume in GB
    volume_type           = "gp3" # General-purpose SSD for better performance
    delete_on_termination = true  # Automatically delete volume when instance is terminated
  }
}

# Output the public IP of the EC2 instance for easy access
output "ec2_endpoint" {
  value = aws_instance.wordpress_ec2.public_ip # Retrieves the public IP address of the instance
}

# Output the EC2 instance ID
output "ec2_instance_id" {
  value = aws_instance.wordpress_ec2.id
}
