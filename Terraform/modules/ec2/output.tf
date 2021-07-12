output "bastion_private_key" {
    value = tls_private_key.pk.private_key_pem
    sensitive = true
} 

output "service_private_key" {
    value = tls_private_key.service_pk.private_key_pem
    sensitive = true
}

output "bastion_host_ip_list" {
   value = aws_instance.bastion.*.public_ip
}

output "bastion_host_hostname_list" {
   value = aws_instance.bastion.*.public_dns
}

output "ec2_read_only_accsess_key" {
    value = aws_iam_access_key.ec2_read_only.id
    sensitive = true
} 

output "ec2_read_only_secret_key" {
    value = aws_iam_access_key.ec2_read_only.secret
    sensitive = true
} 
