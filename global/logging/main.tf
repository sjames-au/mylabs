
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

terraform {
  required_version = ">= 0.12"
}

data "aws_caller_identity" "current" {}

# TODO Enable encryption for trail
resource "aws_cloudtrail" "mylabs-staging-trail" {
  name                          = "mylabs-staging-trail"
  s3_bucket_name                = aws_s3_bucket.mylabs-log-bucket.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
}
resource "aws_kms_key" "mylabs-staging-log-key" {
  description         = "This key is used to encrypt mylabs logging bucket objects"
  enable_key_rotation = true
}

# For self logging you need to use a variable for name as per:
# https://github.com/terraform-providers/terraform-provider-aws/issues/795#issuecomment-330238089
resource "aws_s3_bucket" "mylabs-log-bucket" {
  bucket        = var.log_bucket_name
  force_destroy = true
  acl           = "log-delivery-write"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.mylabs-staging-log-key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  logging {
    target_bucket = var.log_bucket_name
    target_prefix = "s3"
  }

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${var.log_bucket_name}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.log_bucket_name}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}

