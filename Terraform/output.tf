# output "az_list" {
#   value = module.vpc.az_list
# }

output "bastion_host_ip_list" {
   value = module.ec2.bastion_host_ip_list
}

output "bastion_host_hostname_list" {
   value = module.ec2.bastion_host_hostname_list
}

output "bastion_user_access_key" {
    value = module.ec2.ec2_read_only_accsess_key
    sensitive = true
} 

output "bastion_user_secret_key" {
    value = module.ec2.ec2_read_only_secret_key
    sensitive = true
} 

output "s3_access_key" {
    value = module.s3.s3_read_write_access_key
    sensitive = true
} 

output "s3_secret_key" {
    value = module.s3.s3_read_write_secret_key
    sensitive = true
} 

output "aws_region" {
    value = var.aws_region
}

output "s3_bucket_name" {
  value = var.s3_bucket_name
}