data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Create a customer-managed KMS key for SNS encryption with CloudWatch permissions
resource "aws_kms_key" "sns" {
  count               = var.enable_encryption ? 1 : 0
  description         = "KMS key for SNS topic ${var.name}"
  enable_key_rotation = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow CloudWatch to use the key"
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow SNS to use the key"
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

resource "aws_kms_alias" "sns" {
  count         = var.enable_encryption ? 1 : 0
  name          = "alias/${var.name}"
  target_key_id = aws_kms_key.sns[0].key_id
}

resource "aws_sns_topic" "this" {
  name              = var.name
  display_name      = var.display_name
  kms_master_key_id = var.enable_encryption ? aws_kms_key.sns[0].id : null
  tags              = var.tags
}

resource "aws_sns_topic_policy" "this" {
  arn = aws_sns_topic.this.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudWatchAlarms"
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action = [
          "SNS:Publish"
        ]
        Resource = aws_sns_topic.this.arn
      },
      {
        Sid    = "AllowAWSChatbot"
        Effect = "Allow"
        Principal = {
          Service = "chatbot.amazonaws.com"
        }
        Action = [
          "SNS:Subscribe"
        ]
        Resource = aws_sns_topic.this.arn
      }
    ]
  })
}

# Optional: Add email subscription for fallback notifications
resource "aws_sns_topic_subscription" "email" {
  count     = var.email_address != "" ? 1 : 0
  topic_arn = aws_sns_topic.this.arn
  protocol  = "email"
  endpoint  = var.email_address
}
