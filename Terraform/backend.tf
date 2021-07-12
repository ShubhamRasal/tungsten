terraform {
 backend "s3" {
 bucket = "terraform-backend-shubham-rasal"
 key = "one2n/terraform.tfstate"
 region = "ap-south-1"
 dynamodb_table = "tfstate_lock"
 }
}
