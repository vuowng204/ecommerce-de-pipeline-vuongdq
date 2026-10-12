// cấu hình bucket
resource "aws_s3_bucket" "dlt_staging" {
  bucket        = "${var.project_name}-dlt-staging-${var.account_id}"
  force_destroy = true

  // Ghi đè tag để đảm bảo bucket nhận tags.
  tags = {
    Name        = "${var.project_name}-dlt-staging-${var.account_id}"
    Environment = var.environment
  }

}

// cấu hình bảo mật ngăn chặn ACL(Access Control List) tùy ý chỉnh sửa bucket
resource "aws_s3_bucket_public_access_block" "dlt_staging" {
  bucket                  = aws_s3_bucket.dlt_staging.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

// Câu hình Mã hóa phía máy chủ để dữ liệu được mã hóa khi đẩy lên bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "dlt_staging" {
  bucket = aws_s3_bucket.dlt_staging.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

// Câu hình Lifecycle Rule cho dữ liệu trong bucket - để xóa file đã có hết hạn
resource "aws_s3_bucket_lifecycle_configuration" "dlt_staging" {
  bucket = aws_s3_bucket.dlt_staging.id
  rule {
    id     = "expire-staging-files"
    status = "Enabled"
    filter {}
    expiration {
      days = 7
    }
  }
}