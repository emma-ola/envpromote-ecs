resource "aws_sns_topic" "this" {
  name              = var.name
  display_name      = var.display_name
  kms_master_key_id = var.enable_encryption ? "alias/aws/sns" : null
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
