
########################### Staging VPC Config ##################################

variable "aws_profile" {
  description = "AWS Credential profile to use for VPC management"
}

variable "vpc_name" {
  description = "VPC for building demos"
}

variable "aws_region" {
  description = "AWS region"
}

# variable "availability_zone" {
#   description = "availability zone used for the demo, based on region"
# }

variable "vpc_cidr_block" {
  description = "Uber IP addressing for demo Network"
}

variable "vpc_public_subnet_a_cidr" {
  description = "Public 0.0 CIDR for externally accessible subnet"
}

variable "vpc_private_subnet_a_cidr" {
  description = "Private CIDR for internally accessible subnet"
}
variable "vpc_protected_subnet_a_cidr" {
  description = "Protected CIDR for internally accessible subnet"
}
variable "vpc_mgmt_subnet_a_cidr" {
  description = "Management CIDR for management subnet"
}
variable "vpc_cvpn_subnet_a_cidr" {
  description = "Client VPN CIDR for Client VPN Access"
}