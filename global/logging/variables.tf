variable "aws_profile" {
  type        = string
  description = "The AWS Credential profile to use for the lab"
}

variable "aws_region" {
  type        = string
  description = "The AWS region you are deploying to"
}

variable "log_bucket_name" {
  type        = string
  description = "The name for the log bucket"
  default     = "mylabs-log-bucket"
}

variable "enable_flow_log" {
  type        = bool
  description = "Set to True to disable flow logs"
  default     = false
}
