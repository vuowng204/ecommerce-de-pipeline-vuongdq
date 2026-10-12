resource "random_password" "redshift_admin" {
  length  = 24
  special = true
  // chỉ định bọ ký tự đặc biệt nào được sử dụng
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "redshift_admin" {
  name        = "${var.project_name}/redshift/admin"
  description = "Redshift admin credentials"
  // xóa secret khi không còn dùng tránh lỗi secret đã tồn tại khi destroy và apply  lại 
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "redshift_admin" {
  secret_id = aws_secretsmanager_secret.redshift_admin.id

  secret_string = jsonencode({
    username = var.redshift_admin_username
    password = random_password.redshift_admin.result
    //Lấy thẳng địa chỉ Endpoint (URL kết nối) của cụm Redshift Serverless vừa được tạo xong
    // khi aws tạo 1 redshiftserverless nó sẽ trả về 1 chuỗi endpoint và [0] là để truy cập vào phần tử đầu tiên của endpoint
    host     = aws_redshiftserverless_workgroup.this.endpoint[0].address
    port     = aws_redshiftserverless_workgroup.this.endpoint[0].port
    database = "dev"
  })
}