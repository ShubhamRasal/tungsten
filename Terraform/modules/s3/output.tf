output "s3_read_write_access_key" {
    value = aws_iam_access_key.s3_read_write_access_key.id
    sensitive = true
} 

output "s3_read_write_secret_key" {
    value = aws_iam_access_key.s3_read_write_access_key.secret
    sensitive = true
} 
