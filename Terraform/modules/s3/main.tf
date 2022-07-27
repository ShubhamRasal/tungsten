 resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  acl    = "private"
  lifecycle {
    prevent_destroy = false
  }
  tags = {
    "Name" = "${var.project_prefix}-s3-bucket"
  }
  force_destroy =  true
}

