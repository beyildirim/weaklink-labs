variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-west-1"
}

variable "bucket_name" {
  description = "Name for the S3 bucket"
  type        = string
  default     = "webapp-data-prod"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"
}

variable "alarm_email" {
  description = "Email for CloudWatch alarm notifications"
  type        = string
  default     = "ops@example.com"
}
