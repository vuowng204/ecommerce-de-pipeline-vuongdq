# Lấy default VPC
data "aws_vpc" "default" {
  default = true
}

// cấu hình SG cho Redshift sử dụng VPC có sẵn của aws
resource "aws_security_group" "redshift" {
  name        = "${var.project_name}-redshift-sg"
  description = "Allow Redshift Serverless access from my IP"
  vpc_id      = data.aws_vpc.default.id
  tags = {
    Name = "${var.project_name}-redshift-sg"
  }

  ingress {
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
    description = "Redshift from my IP"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  // tránh việc không thể xóa một Security Group khi vẫn đang có tài nguyên khác sử dụng nó.
  // tạo 1 Sg mới rồi chuyền các tài nguyên đang dùng nó sang sg vừa tạo rồi xáo sg cũ /
  lifecycle {
    create_before_destroy = true
  }
}


