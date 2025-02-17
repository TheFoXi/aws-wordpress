# Define an Elasticache subnet group for Redis
# This allows Redis to be deployed in private subnets
resource "aws_elasticache_subnet_group" "redis_subnet" {
  name       = "wordpress-redis-subnet"                           # Name of the subnet group
  subnet_ids = [var.private_subnet_id_1, var.private_subnet_id_2] # Private subnets where Redis will be deployed
}

# Create an Elasticache Redis cluster
resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "wordpress-redis"                              # Unique identifier for the Redis cluster
  engine               = "redis"                                        # Specify Redis as the caching engine
  engine_version       = "7.1"                                          # Redis version
  node_type            = "cache.t3.micro"                               # Instance type for Redis node
  parameter_group_name = "default.redis7"                               # Use default Redis 7 parameter group
  num_cache_nodes      = 1                                              # Number of cache nodes (1 for standalone Redis)
  subnet_group_name    = aws_elasticache_subnet_group.redis_subnet.name # Associate with the subnet group
  security_group_ids   = [var.redis_sg_id]                              # Attach the security group for controlled access

  tags = {
    Name = "wordpress-redis" # Tag for identification
  }
}

# Output the Redis endpoint for application usage
output "redis_endpoint" {
  value = aws_elasticache_cluster.redis.cache_nodes.0.address # Retrieves the endpoint address
}
