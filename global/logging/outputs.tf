
output "log_bucket_domain_name" {
  value       = aws_s3_bucket.mylabs-log-bucket.bucket_domain_name
  description = "FQDN of log bucket"
}

output "log_bucket_id" {
  value       = aws_s3_bucket.mylabs-log-bucket.id
  description = "Log bucket Name (aka ID)"
}

output "log_bucket_arn" {
  value       = aws_s3_bucket.mylabs-log-bucket.arn
  description = "Log bucket ARN"
}