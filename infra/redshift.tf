# Namespace = database-level config
resource "aws_redshiftserverless_namespace" "this" {
  namespace_name      = "${var.project_name}-ns"
  admin_username      = var.redshift_admin_username
  admin_user_password = random_password.redshift_admin.result
  db_name             = "dev"

  iam_roles = [aws_iam_role.redshift_s3_access.arn]

  # Cho phép dùng Redshift Spectrum (đọc S3 trực tiếp) — tương lai- mặc đinh khi không nêu cụ thể role
  default_iam_role_arn = aws_iam_role.redshift_s3_access.arn
}

# Workgroup = compute + network
resource "aws_redshiftserverless_workgroup" "this" {
  namespace_name = aws_redshiftserverless_namespace.this.namespace_name
  workgroup_name = "${var.project_name}-wg"

  base_capacity = var.redshift_base_rpu
  # QUAN TRỌNG: auto-pause để tiết kiệm chi phí
  # Tối thiểu 60 giây. Dev nên để 300 (5 phút) cho tiện test.
  # Prod nên để 3600 (1 giờ) để đảm bảo performance.
  # Set 0 để tắt (không khuyến nghị cho dev).
  # Redshift Serverless min auto-pause: 60s.


  publicly_accessible = true

  subnet_ids         = data.aws_subnets.default.ids
  security_group_ids = [aws_security_group.redshift.id]
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_redshiftserverless_usage_limit" "daily_limit" {
  resource_arn = aws_redshiftserverless_workgroup.this.arn
  usage_type   = "serverless-compute"
  amount       = 6
  period       = "daily"
  breach_action = "log"
}