

module "vpc" {
  source             = "./modules/vpc"
  availability_zones = var.availability_zones
}

module "sg" {
  source = "./modules/sg"
  vpc_id = module.vpc.aws_vpc_id
}

module "ec2" {
  source = "./modules/ec2"

  ec2_ami       = var.ec2_ami
  instance_type = var.instance_type
  ec2_ssh_key   = var.ec2_ssh_key

  public_subnet_id = module.vpc.public_subnet_1_id
  ec2_sg_id        = module.sg.ec2_sg_id
}

module "redis" {
  source = "./modules/redis"

  private_subnet_id_1 = module.vpc.private_subnet_id_1
  private_subnet_id_2 = module.vpc.private_subnet_id_2
  redis_sg_id         = module.sg.redis_sg_id
}

module "rds" {
  source = "./modules/rds"

  db_engine_version = var.db_engine_version
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password

  private_subnet_id_1 = module.vpc.private_subnet_id_1
  private_subnet_id_2 = module.vpc.private_subnet_id_2
  rds_sg_id           = module.sg.rds_sg_id
}

module "aim" {
  source                 = "./modules/aim"
}

# module "alb" {
#   source = "./modules/alb"
#
#   vpc_id             = module.vpc.aws_vpc_id
#   alb_sg_id          = module.sg.alb_sg_id
#   public_subnet_1_id = module.vpc.public_subnet_1_id
#   public_subnet_2_id = module.vpc.public_subnet_2_id
#   ec2_instance_id    = module.ec2.ec2_instance_id
# }

