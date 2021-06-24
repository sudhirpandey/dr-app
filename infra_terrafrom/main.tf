provider "aws" {
  region = "eu-west-1" 
}

provider "aws" {
  alias  = "eu-north-1"
  region = "eu-north-1"
}


resource "aws_route53_zone" "primary" {
  name  = var.route53_zone_domain
}


module "webapp-eu-west-1" {
  source = "./web_app"
  providers = {
    aws = "aws"
  }
}


module "webapp-eu-north-1" {
  source = "./web_app"
  providers = {
    aws = "aws.eu-north-1"
  }
}

#module "webapp-eu-north-1" {
#  source = "./global_db"
#  vpc_id=module.webapp-eu-west-1.vpc_id
#  db_subnet_group_name=module.webapp-eu-west-1.subnet_ids
#  allowed_cidr_blocks=module.webapp-eu-west-1.subnet_cidrs
#  providers = {
#    aws = "aws"
#  }
#}






