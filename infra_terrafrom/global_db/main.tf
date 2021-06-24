locals {
  name   = "global_mysql_db"
}



module "aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 3.0"

  name                  = local.name
  engine                = "aurora-mysql"
  engine_version        = "5.7.12"
  instance_type         = "db.r5.large"
  instance_type_replica = "db.t3.medium"

  vpc_id                = var.vpc_id
  db_subnet_group_name  = var.subnet_ids
  create_security_group = true
  allowed_cidr_blocks   = var.subnet_cidrs

  replica_count                       = 2
  iam_database_authentication_enabled = true
  create_random_password              = true
  engine_mode = "global"

  apply_immediately   = true
  skip_final_snapshot = true

  db_parameter_group_name         = aws_db_parameter_group.example.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.example.id
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
}

resource "aws_ssm_parameter" "this_master_user" {
  name  = "/rds/master-user"
  type  = "SecureString"
  value = module.aurora.rds_cluster_master_username
}

resource "aws_ssm_parameter" "this_master_pass" {
  name  = "/rds/master-pass"
  type  = "SecureString"
  value = module.aurora.rds_cluster_master_password
}


resource "aws_db_parameter_group" "example" {
  name        = "${local.name}-aurora-db-57-parameter-group"
  family      = "aurora-mysql5.7"
  description = "${local.name}-aurora-db-57-parameter-group"
}

resource "aws_rds_cluster_parameter_group" "example" {
  name        = "${local.name}-aurora-57-cluster-parameter-group"
  family      = "aurora-mysql5.7"
  description = "${local.name}-aurora-57-cluster-parameter-group"
}
