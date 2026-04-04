variable "bucket_name" {
  description = "Name of the S3 bucket to monitor"
  type        = string
}

variable "alarm_email" {
  description = "Email address for alarm notifications"
  type        = string
}
