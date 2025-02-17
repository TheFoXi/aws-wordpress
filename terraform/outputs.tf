# Outputs
output "ec2_public_ip" {
  value = module.ec2.ec2_endpoint
}

output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

output "redis_endpoint" {
  value = module.redis.redis_endpoint
}

# output "readonly_user_access_key" {
#   value = module.aim.readonly_user_access_key
# }
#
# output "readonly_user_secret_key" {
#   value     = module.aim.readonly_user_secret_key
#   sensitive = true
# }

output "alb_dns" {
  value = module.alb.alb_dns
}