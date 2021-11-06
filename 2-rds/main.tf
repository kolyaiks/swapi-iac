provider "aws" {
  region = data.terraform_remote_state.vpc.outputs.region
}

resource "aws_security_group" "to_rds_sg" {
  name = "to_rds_sg"
  description = "Access to RDS MySQL"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    description = "Allow access to RDS MySQL"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

}

module "db" {
  source = "terraform-aws-modules/rds/aws"
  version = "~> 3.0"

  publicly_accessible = var.db_publicly_accessible
  identifier = "rds-db-${data.terraform_remote_state.vpc.outputs.company}"

  engine = "mysql"
  engine_version = "8.0.25"
#  engine_version = "5.7.34"
  instance_class = var.db_instance_type
  allocated_storage = 5

  # To be able to delete infrastructure without additional snapshots
  skip_final_snapshot = var.db_skip_final_snapshot
  name = "test_db"
  username = var.db_user
  password = var.db_password
  port = "3306"

  iam_database_authentication_enabled = false

  multi_az = var.db_multi_az

  vpc_security_group_ids = [
    aws_security_group.to_rds_sg.id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window = "03:00-06:00"

  tags = {
    owner = data.terraform_remote_state.vpc.outputs.company
  }

  # DB subnet group
  //TODO: move to private
  subnet_ids = data.terraform_remote_state.vpc.outputs.public_subnets

  # DB parameter group
#  family = "mysql5.7"
  family = "mysql8.0"

  # DB option group
#  major_engine_version = "5.7"
  major_engine_version = "8.0"

  # Database Deletion Protection
  deletion_protection = false

  parameters = [
    {
      name = "character_set_client"
      value = "utf8mb4"
    },
    {
      name = "character_set_server"
      value = "utf8mb4"
    }
  ]
}