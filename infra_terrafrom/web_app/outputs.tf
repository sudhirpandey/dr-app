output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "vpc_cidr" {
  value = "${module.vpc.vpc_cidr_block}"
}

output "vpc_private_subnet_cidrs" {
  value = "${module.vpc.private_subnets_cidr_blocks}"
}

output "vpc_public_subnet_ids" {
  value = "${module.vpc.private_subnets}"
}