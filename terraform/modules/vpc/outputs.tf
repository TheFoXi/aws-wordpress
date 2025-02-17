# Output the VPC ID for reference
output "aws_vpc_id" {
  description = "Main VPC id"
  value       = aws_vpc.main_vpc.id
}

# Output the public subnet ID
output "public_subnet_1_id" {
  value = aws_subnet.public_subnet.id
}

# Output the public subnet 2 ID
output "public_subnet_2_id" {
  value = aws_subnet.public_subnet_2.id
}

# Output the first private subnet ID
output "private_subnet_id_1" {
  value = aws_subnet.private_subnet_1.id
}

# Output the second private subnet ID
output "private_subnet_id_2" {
  value = aws_subnet.private_subnet_2.id
}
