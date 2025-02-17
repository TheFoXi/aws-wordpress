# Terraform module for defining VPC and networking resources

# Main Virtual Private Cloud (VPC) with a CIDR block of 10.0.0.0/16
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "wordpress-vpc"
  }
}

# Public subnet for hosting EC2 instances
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true # Assigns public IP to instances in this subnet
  availability_zone       = var.availability_zones[0]
  tags = {
    Name = "public-subnet"
  }
}

# Public subnet for ALB
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zones[1]

  tags = {
    Name = "public-subnet-2"
  }
}

# Private subnet for RDS and Redis, without public IP assignment
resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false
  availability_zone       = var.availability_zones[0]
  tags = {
    Name = "private-subnet"
  }
}

# Second private subnet for redundancy (placed in another availability zone)
resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = false
  availability_zone       = var.availability_zones[1]
  tags = {
    Name = "private-subnet-2"
  }
}

# Internet Gateway to allow internet access for public subnets
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "main-gateway"
  }
}

# Route Table for the public subnet to enable internet connectivity
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0" # Default route to the internet
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public-route-table"
  }
}

# Associate the public subnet with the public route table
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}
