
output "vpc_region" {
  value = var.aws_region
}

output "vpc_staging_id" {
  value = aws_vpc.vpc_staging.id
}

output "vpc_staging_public_sn_a_id" {
  value = aws_subnet.vpc_staging_public_sn_a.id
}

output "vpc_staging_private_sn_a_id" {
  value = aws_subnet.vpc_staging_private_sn_a.id
}

output "vpc_staging_protected_sn_a_id" {
  value = aws_subnet.vpc_staging_protected_sn_a.id
}

output "vpc_staging_mgmt_sn_a_id" {
  value = aws_subnet.vpc_staging_mgmt_sn_a.id
}

output "vpc_staging_cvpn_sn_a_id" {
  value = aws_subnet.vpc_staging_cvpn_sn_a.id
}

output "vpc_mgmt_subnet_a_cidr" {
  value = aws_subnet.vpc_staging_mgmt_sn_a.cidr_block
}