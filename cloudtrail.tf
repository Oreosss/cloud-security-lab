resource "aws_cloudtrail" "main" {
  name           = "security-lab-trail"
  s3_bucket_name = aws_s3_bucket.main.id
  is_multi_region_trail = true
  enable_log_file_validation = true
  sns_topic_name = aws_sns_topic.security_lab_updates.name
  kms_key_id = aws_kms_key.cloudtrail.arn
}

resource "aws_sns_topic" "security_lab_updates"{
    name = "security-lab-topic"
    kms_master_key_id = aws_kms_key.cloudtrail.arn
}

resource "aws_kms_key" "cloudtrail"{
    description = "KMS key for Cloudtrail"
    deletion_window_in_days = 7
    enable_key_rotation     = true

    policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "Enable IAM root permissions"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::000000000000:root" }
        Action    = "kms:*"
        Resource  = "*"
      }
    ]
  })
}