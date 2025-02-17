# Output the ALB's DNS name for accessing the WordPress site
output "alb_dns" {
  description = "DNS name of the ALB"
  value       = aws_lb.wordpress_alb.dns_name # Retrieve the DNS name of the ALB
}