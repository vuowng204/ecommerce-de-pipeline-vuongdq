// cấu hình IAM role cho Redshift 
resource "aws_iam_role" "redshift_s3_access" {
  name = "${var.project_name}-redshift-s3-role"
  tags = {
    Name        = "${var.project_name}-redshift-s3-role"
    Environment = var.environment
  }
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "redshift.amazonaws.com"
        }
      }
    ]
  })
}
// cấu hình IAM policy cho Redshift 
// Lưu ý :aws_iam_policy + attachment Nhiều role, Xóa role không xóa policy, có thể tái sử dụng,Policy dùng chung
resource "aws_iam_role_policy" "redshift_s3_access" {
  name = "${var.project_name}-redshift-s3-policy"
  role = aws_iam_role.redshift_s3_access.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:GetBucketLocation", // thiếu s3:GetBucketLocation có thể gây lỗi 
          "s3:GetObjectVersion",
        ]
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.dlt_staging.arn,
          "${aws_s3_bucket.dlt_staging.arn}/*"
        ]
      }
    ]
  })
}