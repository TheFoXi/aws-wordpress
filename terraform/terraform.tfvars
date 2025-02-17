# Global settings
region             = "eu-west-1"                  # AWS region where resources will be deployed
availability_zones = ["eu-west-1a", "eu-west-1b"] # List of availability zones for redundancy

# EC2 Configuration
ec2_ami       = "ami-03fd334507439f4d1" # Ubuntu 24.04 AMI ID for the selected region
instance_type = "t2.micro"              # Instance type, optimized for Free Tier (suitable for testing)
ec2_ssh_key   = "wordpress"             # Name of the SSH key pair for secure access to the instance

# MySQL Database Configuration
db_engine_version = "8.0.40"                 # Version of MySQL to be used in the RDS instance
db_name           = "wordpress"              # Name of the WordPress database
db_username       = "wp_user"                # Database username for authentication
db_password       = "SuperSecurePassword123" # Database password (should be stored securely)