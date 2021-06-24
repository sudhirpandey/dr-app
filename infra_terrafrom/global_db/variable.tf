variable "subnet_cidrs" {
  description = "Subnet cidr blocks for service network configuration."
}

variable "subnet_ids" {
  description = "Subnets for service network configuration."
}

variable "vpc_id" {
  description = "The vpc in which the service shall run."
}