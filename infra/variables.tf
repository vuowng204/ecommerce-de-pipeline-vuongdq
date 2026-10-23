variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "ap-southeast-1"
}

variable "project_name" {
  type        = string
  description = "Tên của dự án"
  default     = "ecommerce-de-pipeline"
}

variable "environment" {
  type        = string
  description = "Môi trường của dự án"
  default     = "dev"
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
}


variable "my_ip_cidr" {
  description = "Your public IP in CIDR, e.g. 1.2.3.4/32"
  type        = string
}

variable "redshift_admin_username" {
  description = "Redshift admin username"
  type        = string
  default     = "admin"
}

variable "redshift_base_rpu" {
  description = "Base RPU capacity (8, 16, 32, ...)"
  type        = number
  default     = 4
}