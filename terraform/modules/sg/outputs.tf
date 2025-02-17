# Output the security group ID for EC2
output "ec2_sg_id" {
  value = aws_security_group.ec2_sg.id
}

# Output the security group ID for RDS
output "rds_sg_id" {
  value = aws_security_group.rds_sg.id
}

# Output the security group ID for Redis
output "redis_sg_id" {
  value = aws_security_group.redis_sg.id
}

# Output the security group ID for ALB
output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}