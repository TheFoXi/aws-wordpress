variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "availability_zones" {
  type    = list(string)
  default = ["eu-west-1a", "eu-west-1b"]
}

# EC2
variable "instance_type" { type = string }
variable "ec2_ami" { type = string }
variable "ec2_ssh_key" { type = string }

# MySQL
variable "db_engine_version" { type = string }
variable "db_name" { type = string }
variable "db_username" { type = string }
variable "db_password" { type = string }