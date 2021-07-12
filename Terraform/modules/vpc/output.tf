output "az_list" {
  value = null_resource.az_names.triggers.names
}
output "public_subnet_list" {
  value = aws_subnet.public.*.id
}
output "private_subnet_list" {
  value = aws_subnet.private.*.id
}
output "vpc_id" {
  value = aws_vpc.vpc.id
}