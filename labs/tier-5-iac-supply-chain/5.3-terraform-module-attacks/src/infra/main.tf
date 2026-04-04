# Infrastructure configuration
# Uses a community module for S3 bucket creation

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# S3 bucket for application data
# Source: "trusted" community module from the registry
module "storage" {
  source  = "community-modules/s3-bucket/aws"
  version = ">=3.0.0"

  bucket_name = var.bucket_name
  environment = var.environment

  versioning = true
  encryption = true

  tags = {
    Project     = "webapp"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# CloudWatch alarms for the bucket
module "monitoring" {
  source = "./modules/monitoring"

  bucket_name = module.storage.bucket_id
  alarm_email = var.alarm_email
}

output "bucket_arn" {
  value = module.storage.bucket_arn
}

output "bucket_name" {
  value = module.storage.bucket_id
}
