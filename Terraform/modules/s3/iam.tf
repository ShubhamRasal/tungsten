
resource "aws_iam_user" "s3_read_only" {
  name = "s3_read_only"
  path = "/system/"

  tags = {
    "Name" = "${var.project_prefix}-s3_read_only"
  }
}

resource "aws_iam_access_key" "s3_read_only_access_key" {
  user = aws_iam_user.s3_read_only.name
}

resource "aws_iam_user_policy" "s3_read_only" {
  name = "s3_read_only"
  user = aws_iam_user.s3_read_only.name
  policy = templatefile("${path.module}/bucket_read_only_policy.tmpl", {bucket_name = var.bucket_name})
}




#-------------------------------------------------------------------------------
# IAM user with read write access
#-------------------------------------------------------------------------------
resource "aws_iam_user" "s3_read_write" {
  name = "s3_read_write"
  path = "/system/"

  tags = {
    "Name" = "${var.project_prefix}-s3_read_write"
  }
}

resource "aws_iam_access_key" "s3_read_write_access_key" {
  user = aws_iam_user.s3_read_write.name
}

resource "aws_iam_user_policy" "s3_read_write" {
  name = "s3_read_write"
  user = aws_iam_user.s3_read_write.name
  policy = templatefile("${path.module}/bucket_read_write_policy.tmpl", {bucket_name = var.bucket_name})
}