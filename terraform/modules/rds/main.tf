# Define a DB subnet group for RDS
# This ensures RDS is deployed in private subnets
resource "aws_db_subnet_group" "db_subnet" {
  name       = "wordpress-db-subnet"                              # Name of the DB subnet group
  subnet_ids = [var.private_subnet_id_1, var.private_subnet_id_2] # List of private subnets

  tags = {
    Name = "wordpress-db-subnet" # Tag for identification
  }
}

# Create an RDS MySQL instance for WordPress
resource "aws_db_instance" "wordpress_db" {
  allocated_storage      = 20                                 # Free Tier requirement - 20GB of storage
  instance_class         = "db.t3.micro"                      # Free Tier requirement - Small instance type
  engine                 = "mysql"                            # Database engine type
  engine_version         = var.db_engine_version              # MySQL version specified in variables
  db_name                = var.db_name                        # Database name
  username               = var.db_username                    # Database username
  password               = var.db_password                    # Database password (should be stored securely)
  vpc_security_group_ids = [var.rds_sg_id]                    # Attach security group to control access
  db_subnet_group_name   = aws_db_subnet_group.db_subnet.name # Associate with the subnet group
  publicly_accessible    = false                              # Ensures the database is private
  multi_az               = false                              # Single Availability Zone (disable Multi-AZ for cost savings)
  skip_final_snapshot    = true                               # Avoids storing a final snapshot before deletion
  deletion_protection    = false                              # Allows instance to be deleted when no longer needed

  tags = {
    Name = "wordpress-rds" # Tag for easy identification
  }
}

# Output the RDS endpoint for application connection
output "rds_endpoint" {
  value = aws_db_instance.wordpress_db.endpoint # Retrieves the database endpoint
}
