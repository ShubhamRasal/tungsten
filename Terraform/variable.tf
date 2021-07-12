
variable "author" {
  type = string
}

variable "project_name" {
  type = string
}

variable "env" {
   type = string
}

variable "max_az" {
   type =  number
}

variable "vpc_cidr" {
  type = string
}

variable "s3_bucket_name" {
  type =  string
}

variable "aws_region" {
  type =  string
  default = "ap-south-1"
}

locals {
  project_prefix = "${var.project_name}-${var.env }"
}

variable "rds" {
  type = object({
    allocated_storage = number
    engine            = string
    engine_version    = string 
    instance_class    = string
    name              = string
  })
}

variable "rds_username"{
  type = string
}

variable "rds_password" {
  type =  string
  sensitive   = true
}

variable "bastion" {
  type = object({
    count = number
    ami   = string
    type  = string
  })
}

variable "service_box" {
  type = object({
    count = number
    ami   = string
    type  = string
    extra_ebs_size = number
  })
}

variable "sg_service_rules" {
  type = list
}

variable "alb_target_groups" {
  type =  list
}

variable "certificate_arn" {
  type = string
}