# Monitoring module - this one is clean
# Creates CloudWatch alarms for S3 bucket metrics

resource "aws_sns_topic" "alerts" {
  name = "${var.bucket_name}-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

resource "aws_cloudwatch_metric_alarm" "bucket_size" {
  alarm_name          = "${var.bucket_name}-size-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "BucketSizeBytes"
  namespace           = "AWS/S3"
  period              = 86400
  statistic           = "Average"
  threshold           = 5368709120 # 5 GB
  alarm_description   = "S3 bucket size exceeds 5GB"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    BucketName  = var.bucket_name
    StorageType = "StandardStorage"
  }
}
