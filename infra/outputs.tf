//Đường dẫn vào redshiftserverless
output "redshift_endpoint" {
  description = "Redshift Serverless endpoint"
  value       = "${aws_redshiftserverless_workgroup.this.endpoint[0].address}:${aws_redshiftserverless_workgroup.this.endpoint[0].port}"
}

//tên database trong namespace 
output "redshift_database" {
  description = "Redshift database name"
  value       = aws_redshiftserverless_namespace.this.db_name
}

//Giá trị ARN(aws resource name) của secret manager
output "redshift_secret_arn" {
  description = "ARN of Secrets Manager secret with Redshift credentials"
  value       = aws_secretsmanager_secret.redshift_admin.arn
}

//.bucket là để lấy tên của bucket , ví dụ khi cần để tải file lên, đọc file, hoặc khi bạn cấu hình lệnh COPY trong Redshift để trỏ đến đường dẫn: s3://ten-bucket/du-lieu/, thì thứ  cần truyền vào code bắt buộc phải là tên của bucket (bucket), chứ không thể truyền cả một chuỗi ARN dài dằng dặc được.
output "s3_staging_bucket" {
  description = "S3 bucket used as dlt staging"
  value       = aws_s3_bucket.dlt_staging.bucket
}

output "redshift_iam_role_arn" {
  description = "IAM Role ARN for Redshift to access S3"
  value       = aws_iam_role.redshift_s3_access.arn
}