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
variable "rds_password"{
  type = string
  sensitive   = true
}
variable "vpc_id" {
  type = string
}

variable "project_prefix" {
  type  = string
}

variable "aws_private_subnet_ids" {
  type =  list(string)
  default = [  ]
}
