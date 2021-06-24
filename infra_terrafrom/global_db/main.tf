locals {
  name   = "global-mysql-db"
}

provider "aws" {
  alias  = "primary"
  region = "eu-west-1" 
}

provider "aws" {
  alias  = "secondary"
  region = "eu-north-1"
}

resource "aws_db_subnet_group" "rds-private-subnet-euwest1" {
  name = "rds-private-subnet-group"
  subnet_ids = var.euwest1_subnet_cidrs
}

resource "random_password" "master" {
  length = 10
}

resource "aws_db_subnet_group" "rds-private-subnet-eunorth1" {
  name = "rds-private-subnet-group"
  subnet_ids = var.eunorth1_subnet_cidrs
}

resource "aws_rds_global_cluster" "global_db_cluster" {
  global_cluster_identifier = "global-db-test"
  engine                    = "aurora"
  engine_version            = "5.6.mysql_aurora.1.22.2"
  database_name             = "app_db"
}

resource "aws_rds_cluster" "primary" {
  provider                  = aws.primary
  engine                    = aws_rds_global_cluster.global_db_cluster.engine
  engine_version            = aws_rds_global_cluster.global_db_cluster.engine_version
  cluster_identifier        = "primary-cluster"
  master_username           = "master"
  master_password           = random_password.master.result
  database_name             = "app_db"
  global_cluster_identifier = aws_rds_global_cluster.global_db_cluster.id
  db_subnet_group_name      = aws_db_subnet_group.rds-private-subnet-euwest1.name
}

resource "aws_rds_cluster_instance" "primary" {
  count                = 2
  provider             = aws.primary
  identifier           = format("%s-%s", "primary-cluster-instance", count.index)
  cluster_identifier   = aws_rds_cluster.primary.id
  instance_class       = "db.r5.large"
  db_subnet_group_name = aws_db_subnet_group.rds-private-subnet-euwest1.name
}

resource "aws_rds_cluster" "secondary" {
  provider                  = aws.secondary
  engine                    = aws_rds_global_cluster.global_db_cluster.engine
  engine_version            = aws_rds_global_cluster.global_db_cluster.engine_version
  cluster_identifier        = "secondary-cluster"
  global_cluster_identifier = aws_rds_global_cluster.global_db_cluster.id
  db_subnet_group_name      = aws_db_subnet_group.rds-private-subnet-eunorth1.name
}

resource "aws_rds_cluster_instance" "secondary" {
  count                = 1
  provider             = aws.secondary
  identifier           = format("%s-%s", "secondary-cluster-instance", count.index)
  cluster_identifier   = aws_rds_cluster.secondary.id
  instance_class       = "db.rr.large"
  db_subnet_group_name = aws_db_subnet_group.rds-private-subnet-eunorth1.name

  depends_on = [
    aws_rds_cluster_instance.primary
  ]
}



resource "aws_ssm_parameter" "this_master_pass" {
  name  = "/rds/master-pass"
  type  = "SecureString"
  value = random_password.master.result
}

