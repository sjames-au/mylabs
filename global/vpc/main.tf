
# Setup our aws provider
provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

terraform {
  required_version = ">= 0.12"
}

data "aws_availability_zones" "available" {
  state = "available"
}


# Define a vpc
resource "aws_vpc" "vpc_staging" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = var.vpc_name
  }
}

# Internet gateway for the public subnet
resource "aws_internet_gateway" "staging_ig" {
  vpc_id = aws_vpc.vpc_staging.id
  tags = {
    Name = "staging_ig"
  }
}

# Public subnet
resource "aws_subnet" "vpc_staging_public_sn_a" {
  vpc_id            = aws_vpc.vpc_staging.id
  cidr_block        = var.vpc_public_subnet_a_cidr
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "vpc_staging_public_sn_a"
  }
}

# Private subnet
resource "aws_subnet" "vpc_staging_private_sn_a" {
  vpc_id            = aws_vpc.vpc_staging.id
  cidr_block        = var.vpc_private_subnet_a_cidr
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "vpc_private_sn_a"
  }
}

# Protected subnet
resource "aws_subnet" "vpc_staging_protected_sn_a" {
  vpc_id            = aws_vpc.vpc_staging.id
  cidr_block        = var.vpc_protected_subnet_a_cidr
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "vpc_protected_sn_a"
  }
}

# Management subnet
resource "aws_subnet" "vpc_staging_mgmt_sn_a" {
  vpc_id            = aws_vpc.vpc_staging.id
  cidr_block        = var.vpc_mgmt_subnet_a_cidr
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "vpc_mgmt_sn_a"
  }
}

resource "aws_subnet" "vpc_staging_cvpn_sn_a" {
  vpc_id            = aws_vpc.vpc_staging.id
  cidr_block        = var.vpc_cvpn_subnet_a_cidr
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "vpc_cvpn_sn_a"
  }
}

# Routing table for public subnet
resource "aws_route_table" "vpc_staging_public_sn_a_rt" {
  vpc_id = aws_vpc.vpc_staging.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.staging_ig.id
  }
  tags = {
    Name = "vpc_staging_public_sn_a_rt"
  }
}

# Associate the routing table to public subnet
resource "aws_route_table_association" "vpc_public_sn_rt_assn" {
  subnet_id      = aws_subnet.vpc_staging_public_sn_a.id
  route_table_id = aws_route_table.vpc_staging_public_sn_a_rt.id
}
