
variable "aws_profile" {
  description = "AWS Credential profile to use for VPC management"
}

variable "aws_region" {
  description = "AWS region operating in"
}

variable "bastion_key" {
  type        = string
  description = "The key to be used for password encryption"
}