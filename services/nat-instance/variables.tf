
variable "aws_profile" {
  description = "AWS Credential profile to use for VPC management"
}

variable "aws_region" {
  description = "AWS region operating in"
}

variable "allow_admin_cidr" {
  description = "A range that can access via SSH use /32 for single IP"
}

variable "logz_secret_id" {
  type        = string
  description = "Name identifier for the logz.io authentication information"
}

variable "bastion_ddns_secret_id" {
  type        = string
  description = "Name identifier for the ddns authentication information"
}

variable "logz_endpoint" {
  type        = string
  description = "End point location for logz"
}

variable "bastion_key" {
  type        = string
  description = "The named SSH key to use for accessing the Bastion"
}

variable "bastion_fqdn" {
  type        = string
  description = "FQDN for bastion host"
}

variable "bastion_ddns_server" {
  type        = string
  description = "server name for ddclient update"
}